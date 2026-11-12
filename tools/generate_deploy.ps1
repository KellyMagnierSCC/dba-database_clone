<#
.SYNOPSIS
    Regenerate the deployment scripts and the extended-property script from the manifests.

.DESCRIPTION
    Source of truth (edit these, then re-run this script):
        10_metadata\object_manifest.csv   one row per object: placement, package, dependencies, deploy order
        10_metadata\packages.csv          one row per deployment package
        10_metadata\rename_map.csv        old -> new names (record of the v3 rename; no migration is generated)
        10_metadata\migration_manifest.csv  one row per 08_migrations script: file name and the object it changes
        10_metadata\reference_data_manifest.csv  one row per 11_reference_data script: file name and the table it loads

    Migrations run after 04_tables and before 05_views, in file-name order. deploy_all runs every
    migration; a package script runs the migrations whose object is in that package. Each run is
    recorded in dbo.Migration_History. Every .sql file in 08_migrations must be listed.

    Reference data runs last, after the procedures, in the DeployOrder of the tables it loads.
    deploy_all runs every script; a package script runs the scripts for the tables it deploys.
    Every .sql file in 11_reference_data must be listed, and is named after its table.

    Generated (do not hand-edit):
        tools\find_old_name_references.sql   diagnostic - NOT deployed
        09_deployment\deploy_all.sql
        09_deployment\deploy_third_party.sql
        09_deployment\packages\deploy_<package>.sql
        10_metadata\apply_extended_properties.sql

.EXAMPLE
    # From the repository root:
    .\tools\generate_deploy.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root     = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$Manifest = Join-Path $Root '10_metadata\object_manifest.csv'
$Packages = Join-Path $Root '10_metadata\packages.csv'
$Renames  = Join-Path $Root '10_metadata\rename_map.csv'
$Migrations   = Join-Path $Root '10_metadata\migration_manifest.csv'
$MigrationDir = Join-Path $Root '08_migrations'
$MigrationLog = 'Migration_History'
$RefData      = Join-Path $Root '10_metadata\reference_data_manifest.csv'
$RefDataDir   = Join-Path $Root '11_reference_data'

$Level1Type = @{ Table = 'TABLE'; View = 'VIEW'; Procedure = 'PROCEDURE' }

$HeaderRule = '-- ' + ('=' * 76)

$RunNote = @(
    'Settings are supplied when you deploy, not stored in the repo (see 09_deployment\config.sql).',
    'sqlcmd:',
    '  sqlcmd -S <instance> -E -b -v RepoRoot="D:\DevOps\dba-database" DatabaseName="DBA" -i <this file>',
    'SSMS (Query > SQLCMD Mode): run your own 09_deployment\local_deploy.sql',
    '  (copy local_deploy.example.sql; it is not committed).',
    'RepoRoot must be a full path without spaces: the :r paths are unquoted because SSMS',
    'does not expand variables inside a quoted path.'
)

# Lines shared by every generated deploy script. RepoRoot and DatabaseName are not set here: the
# caller supplies them, because a :setvar in the script would override sqlcmd -v
# :r paths are unquoted: SSMS does not expand $(RepoRoot) inside a quoted :r path
$ConfigLine  = ':r $(RepoRoot)\09_deployment\config.sql'
$MetaLine    = ':r $(RepoRoot)\10_metadata\apply_extended_properties.sql'

# ---------------------------------------------------------------- helpers

function Read-Csv([string]$Path) {
    # Import-Csv with UTF8 strips a BOM, matching Python's utf-8-sig
    return @(Import-Csv -Path $Path -Encoding UTF8)
}

function Write-TextFile([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    # Normalise to LF, write UTF-8 with BOM (same as utf-8-sig, newline="\n")
    $Text = $Text -replace "`r`n", "`n"
    $enc = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

function ConvertTo-SqlString([string]$s) {
    return "N'" + $s.Replace("'", "''") + "'"
}

function ConvertTo-RPath([string]$RepoPath) {
    # Repo path -> sqlcmd :r argument rooted at $(RepoRoot) (Windows separators). Unquoted, because
    # SSMS does not expand variables inside a quoted :r path, so the path cannot contain spaces
    if ($RepoPath.Contains(' ')) { throw "RepoPath contains a space, which an unquoted :r path cannot hold: $RepoPath" }
    return '$(RepoRoot)\' + $RepoPath.Replace('/', '\')
}

function Get-OrdinalSorted([string[]]$Items) {
    $arr = [string[]]@($Items)
    [Array]::Sort($arr, [System.StringComparer]::Ordinal)
    return , $arr
}

function Import-Manifest {
    $rows = Read-Csv $Manifest
    $seq = 0
    $objs = foreach ($r in $rows) {
        [pscustomobject]@{
            Seq             = $seq++
            Schema          = $r.Schema
            ObjectName      = $r.ObjectName
            ObjectType      = $r.ObjectType
            RepositoryGroup = $r.RepositoryGroup
            PackageName     = $r.PackageName
            Vendor          = $r.Vendor
            RepoPath        = $r.RepoPath
            DependsOn       = $r.DependsOn
            DeployOrder     = [int]$r.DeployOrder
            IsThirdParty    = ($r.IsThirdParty.Trim().ToLower() -eq 'true')
            Deps            = @($r.DependsOn -split ';' | Where-Object { $_ })
        }
    }
    # Seq as tie-breaker gives a stable sort on every PowerShell version
    $objs = @($objs | Sort-Object -Property DeployOrder, Seq)
    return , @($objs, (Read-Csv $Packages))
}

function Import-Migrations($Objs) {
    $rows = @(Read-Csv $Migrations)
    $names = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($o in $Objs) { [void]$names.Add($o.ObjectName) }

    $listed = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $byFile = @{}
    foreach ($m in $rows) {
        if (-not $listed.Add($m.MigrationFile)) {
            throw "Migration listed twice in migration_manifest.csv: $($m.MigrationFile)"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $MigrationDir $m.MigrationFile) -PathType Leaf)) {
            throw "migration_manifest.csv points at a missing file: 08_migrations\$($m.MigrationFile)"
        }
        if (-not $names.Contains($m.ObjectName)) {
            throw "Migration $($m.MigrationFile) changes an object that is not in object_manifest.csv: $($m.ObjectName)"
        }
        $byFile[$m.MigrationFile] = $m
    }

    # A migration file that is not listed would silently never deploy
    $unlisted = @(Get-ChildItem -LiteralPath $MigrationDir -Filter '*.sql' -File |
                  Where-Object { -not $listed.Contains($_.Name) } | ForEach-Object { $_.Name })
    if ($unlisted.Count -gt 0) {
        throw ("Migrations not listed in migration_manifest.csv:`n  " + ($unlisted -join "`n  "))
    }
    if ($rows.Count -gt 0 -and -not $names.Contains($MigrationLog)) {
        throw "Migrations need $MigrationLog in object_manifest.csv"
    }

    # File names start YYYYMMDD_NN, so ordinal order is run order
    $order = Get-OrdinalSorted ([string[]]@($rows | ForEach-Object { $_.MigrationFile }))
    return , ([object[]]@($order | ForEach-Object { $byFile[$_] }))
}

function Import-ReferenceData($Objs) {
    $rows = @(Read-Csv $RefData)
    $tables = @{}
    foreach ($o in $Objs) { if ($o.ObjectType -eq 'Table') { $tables[$o.ObjectName] = $o } }

    $listed = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $refs = foreach ($r in $rows) {
        $file = $r.DataFile.Replace('\', '/')
        if (-not $listed.Add($file)) {
            throw "Reference data listed twice in reference_data_manifest.csv: $file"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $RefDataDir $file) -PathType Leaf)) {
            throw "reference_data_manifest.csv points at a missing file: 11_reference_data\$file"
        }
        if (-not $tables.ContainsKey($r.ObjectName)) {
            throw "Reference data $file loads a table that is not in object_manifest.csv: $($r.ObjectName)"
        }
        if ([System.IO.Path]::GetFileNameWithoutExtension($file) -cne $r.ObjectName) {
            throw "Reference data file must be named after the table it loads: $file loads $($r.ObjectName)"
        }
        $t = $tables[$r.ObjectName]
        [pscustomobject]@{
            ObjectName  = $r.ObjectName
            RepoPath    = '11_reference_data/' + $file
            DeployOrder = $t.DeployOrder
            Seq         = $t.Seq
        }
    }

    # A data file that is not listed would silently never deploy
    if (Test-Path -LiteralPath $RefDataDir) {
        $unlisted = @(Get-ChildItem -LiteralPath $RefDataDir -Filter '*.sql' -Recurse -File |
                      ForEach-Object { $_.FullName.Substring($RefDataDir.Length).TrimStart('\', '/').Replace('\', '/') } |
                      Where-Object { -not $listed.Contains($_) })
        if ($unlisted.Count -gt 0) {
            throw ("Reference data not listed in reference_data_manifest.csv:`n  " + ($unlisted -join "`n  "))
        }
    }

    # Same order as the tables, so a parent table's rows load before a child's
    return , ([object[]]@($refs | Sort-Object -Property DeployOrder, Seq))
}

function New-Preamble([string]$Title, [string[]]$Lines) {
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add($HeaderRule)
    $out.Add("-- $Title")
    $out.Add($HeaderRule)
    foreach ($l in $Lines) {
        if ($l) { $out.Add("-- $l") } else { $out.Add('--') }
    }
    $out.AddRange([string[]]@(
        $HeaderRule,
        $ConfigLine,
        ':on error exit',
        'GO',
        'USE [$(DatabaseName)]',
        'GO',
        ''
    ))
    return , $out
}

function Get-RLines($Objs) {
    # Leading comma stops PowerShell unrolling a 0/1-element array into $null/a bare string
    return , ([string[]]@($Objs | ForEach-Object { ":r $(ConvertTo-RPath $_.RepoPath)" }))
}

function Get-MigrationLines($Migs, [string]$Script) {
    # Each migration is followed by a row in the migration log; :on error exit stops before the
    # INSERT if the migration fails, so the log only records migrations that completed
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($m in $Migs) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($m.MigrationFile)
        $out.Add(":r $(ConvertTo-RPath ('08_migrations/' + $m.MigrationFile))")
        $out.Add('GO')
        $out.Add("INSERT [dbo].[$MigrationLog] (MigrationName, DeployScript) VALUES ($(ConvertTo-SqlString $name), $(ConvertTo-SqlString $Script));")
        $out.Add('GO')
    }
    return , ([string[]]$out.ToArray())
}

# ---------------------------------------------------------------- generators

function New-DeployAll($Objs, $Migs, $Refs) {
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add($HeaderRule)
    $out.Add('-- deploy_all.sql - full deployment: folders 00-06 in order, with 08_migrations run after 04_tables and 11_reference_data last (idempotent, re-runnable).')
    $out.Add('-- Vendor code can also be deployed on its own with deploy_third_party.sql.')
    $out.Add($HeaderRule)
    foreach ($l in $RunNote) { $out.Add("-- $l") }
    $out.AddRange([string[]]@(
        $HeaderRule,
        $ConfigLine,
        ':on error exit',
        'GO',
        ''
    ))

    $db   = @($Objs | Where-Object { $_.ObjectType -eq 'Database' })
    $rest = @($Objs | Where-Object { $_.ObjectType -ne 'Database' })

    $out.Add('-- 00_database (runs in master)')
    $out.AddRange((Get-RLines $db))
    $out.AddRange([string[]]@('GO', 'USE [$(DatabaseName)]', 'GO', ''))

    $sections = @(
        @{ Name = '01_security';          Pred = { param($o) $o.ObjectType -eq 'Security' } },
        @{ Name = '02_third_party';       Pred = { param($o) $o.IsThirdParty } },
        @{ Name = '03_types (none yet)';  Pred = { param($o) $o.ObjectType -eq 'Type' } },
        @{ Name = '04_tables';            Pred = { param($o) $o.ObjectType -eq 'Table'     -and -not $o.IsThirdParty } },
        @{ Name = '05_views';             Pred = { param($o) $o.ObjectType -eq 'View'      -and -not $o.IsThirdParty } },
        @{ Name = '06_programmability';   Pred = { param($o) $o.ObjectType -eq 'Procedure' -and -not $o.IsThirdParty } }
    )

    $seen = New-Object 'System.Collections.Generic.HashSet[int]'
    foreach ($s in $sections) {
        $pred = $s.Pred
        $sel = @($rest | Where-Object { & $pred $_ })
        foreach ($o in $sel) { [void]$seen.Add($o.Seq) }
        $out.Add("-- $($s.Name) ($($sel.Count) objects)")
        $out.AddRange((Get-RLines $sel))
        $out.Add('')
        if ($s.Name -eq '04_tables') {
            $out.Add("-- 08_migrations ($($Migs.Count) migrations, run after the tables exist and before the views and procedures that use them)")
            $out.AddRange((Get-MigrationLines $Migs 'deploy_all'))
            $out.Add('')
        }
    }

    $missing = @($rest | Where-Object { -not $seen.Contains($_.Seq) })
    if ($missing.Count -gt 0) {
        throw ('Objects not placed in any deploy section: ' + (($missing | ForEach-Object { $_.ObjectName }) -join ', '))
    }

    $out.Add("-- 11_reference_data ($($Refs.Count) tables, run after the procedures so every table and migration is in place)")
    $out.AddRange((Get-RLines $Refs))
    $out.Add('')

    $out.AddRange([string[]]@('-- 10_metadata', $MetaLine, ''))
    return ($out -join "`n")
}

function New-ThirdParty($Objs) {
    $tp = @($Objs | Where-Object { $_.IsThirdParty })
    $out = New-Preamble 'deploy_third_party.sql - vendor code only' (
        @('Deploys every third-party object (Adam Machanic, Ola Hallengren, Brent Ozar, Darling Data).') + $RunNote
    )
    $cur = $null
    foreach ($o in $tp) {
        if ($o.Vendor -ne $cur) {
            $cur = $o.Vendor
            $out.Add("-- $cur")
        }
        $out.Add(":r $(ConvertTo-RPath $o.RepoPath)")
    }
    $out.AddRange([string[]]@('', $MetaLine, ''))
    return ($out -join "`n")
}

function Get-Closure($Objs, [string[]]$Seeds) {
    # Package members plus everything they depend on (custom objects expand; vendor objects do not)
    $byName = @{}
    foreach ($o in $Objs) { $byName[$o.ObjectName] = $o }
    $want  = New-Object 'System.Collections.Generic.HashSet[string]'
    $stack = New-Object 'System.Collections.Generic.Stack[string]'
    foreach ($s in $Seeds) { $stack.Push($s) }
    while ($stack.Count -gt 0) {
        $n = $stack.Pop()
        if ($want.Contains($n)) { continue }
        [void]$want.Add($n)
        if (-not $byName.ContainsKey($n)) {
            throw "Dependency or required object not found in manifest: $n"
        }
        $o = $byName[$n]
        if (-not $o.IsThirdParty) {
            foreach ($d in $o.Deps) { $stack.Push($d) }
        }
    }
    return $want
}

function New-Package($Pkg, $Objs, $Migs, $Refs) {
    $name = $Pkg.PackageName
    $members = @($Objs | Where-Object { $_.PackageName -eq $name -and -not $_.IsThirdParty } |
                 ForEach-Object { $_.ObjectName })
    if ($members.Count -eq 0) { throw "Package has no objects: $name" }

    $seeds = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($m in $members) { [void]$seeds.Add($m) }
    foreach ($r in ($Pkg.ThirdPartyRequires -split ';')) { if ($r) { [void]$seeds.Add($r) } }

    $want = Get-Closure $Objs ([string[]]@($seeds))
    # The package runs the migrations for any table it deploys, so it also needs the migration log
    $pkgMigs = @($Migs | Where-Object { $want.Contains($_.ObjectName) })
    if ($pkgMigs.Count -gt 0) {
        $want = Get-Closure $Objs ([string[]](@($seeds) + $MigrationLog))
    }
    # Vendor rows have ObjectType 'ThirdParty', which is not in $Level1Type, so keep them explicitly
    $sel = @($Objs | Where-Object { $want.Contains($_.ObjectName) -and ($_.IsThirdParty -or $Level1Type.ContainsKey($_.ObjectType)) })
    $vendorSel = @($sel | Where-Object { $_.IsThirdParty })
    $pkgRefs = @($Refs | Where-Object { $want.Contains($_.ObjectName) })
    $sel = @($sel | Where-Object { -not $_.IsThirdParty })

    $pulled = Get-OrdinalSorted (@($sel | Where-Object { $_.PackageName -ne $name } |
                                   ForEach-Object { $_.ObjectName }))
    $vendor = @($vendorSel | ForEach-Object { $_.ObjectName })

    $notes = New-Object System.Collections.Generic.List[string]
    $notes.Add($Pkg.Description)
    $notes.Add('')
    $notes.Add("Own objects: $($members.Count)   Vendor objects: $($vendor.Count)   Pulled from other packages: $($pulled.Count)")
    if ($vendor.Count -gt 0) { $notes.Add('Vendor objects: ' + ($vendor -join ', ')) }
    if ($pulled.Count -gt 0) { $notes.Add('Pulled from other packages: ' + ($pulled -join ', ')) }
    if ($pkgMigs.Count -gt 0) { $notes.Add("Migrations: $($pkgMigs.Count) (run after the tables, before the views and procedures)") }
    if ($pkgRefs.Count -gt 0) { $notes.Add("Reference data: $($pkgRefs.Count) tables (run after the views and procedures)") }
    $notes.Add('')
    $notes.AddRange([string[]]$RunNote)

    $out = New-Preamble "$($Pkg.ScriptName).sql - $name" ([string[]]$notes)
    # Vendor code first, as in deploy_all.sql (02_third_party before 04_tables)
    if ($vendorSel.Count -gt 0) {
        $out.Add("-- 02_third_party ($($vendorSel.Count), from ThirdPartyRequires in packages.csv)")
        $out.AddRange((Get-RLines $vendorSel))
        $out.Add('')
    }
    if ($pkgMigs.Count -gt 0) {
        $out.AddRange((Get-RLines @($sel | Where-Object { $_.ObjectType -eq 'Table' })))
        $out.Add('')
        $out.Add("-- 08_migrations ($($pkgMigs.Count))")
        $out.AddRange((Get-MigrationLines $pkgMigs $Pkg.ScriptName))
        $out.Add('')
        $out.AddRange((Get-RLines @($sel | Where-Object { $_.ObjectType -ne 'Table' })))
    } else {
        $out.AddRange((Get-RLines $sel))
    }
    if ($pkgRefs.Count -gt 0) {
        $out.Add('')
        $out.Add("-- 11_reference_data ($($pkgRefs.Count))")
        $out.AddRange((Get-RLines $pkgRefs))
    }
    $out.AddRange([string[]]@('', $MetaLine, ''))
    return ($out -join "`n")
}

$MetadataTemplate = @'
__RULE__
-- apply_extended_properties.sql  (GENERATED from 10_metadata/object_manifest.csv)
--
-- Stamps RepositoryGroup, PackageName and IsThirdParty on every table, view and
-- procedure. Safe to re-run: adds missing properties, updates changed ones, leaves
-- identical ones alone, and skips objects that are not in this database (so it can
-- be run after a single-package deployment).
--
-- The legacy single 'Package' property is NOT touched by this script.
__RULE__
SET NOCOUNT ON;

DECLARE @Meta TABLE
(
    SchemaName      sysname       NOT NULL,
    ObjectName      sysname       NOT NULL,
    Level1Type      nvarchar(60)  NOT NULL,
    RepositoryGroup nvarchar(128) NOT NULL,
    PackageName     nvarchar(256) NOT NULL,
    IsThirdParty    nvarchar(5)   NOT NULL
);

INSERT @Meta (SchemaName, ObjectName, Level1Type, RepositoryGroup, PackageName, IsThirdParty)
VALUES
__VALS__;

DECLARE @Schema sysname, @Object sysname, @Type nvarchar(60),
        @PropName sysname, @PropValue nvarchar(4000), @Current nvarchar(4000),
        @Added int = 0, @Updated int = 0, @Unchanged int = 0, @Skipped int = 0;

DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT m.SchemaName, m.ObjectName, m.Level1Type, p.PropName, p.PropValue
    FROM @Meta AS m
    CROSS APPLY (VALUES (N'RepositoryGroup', m.RepositoryGroup),
                        (N'PackageName',     m.PackageName),
                        (N'IsThirdParty',    m.IsThirdParty)) AS p (PropName, PropValue)
    ORDER BY m.SchemaName, m.ObjectName, p.PropName;

OPEN c;
FETCH NEXT FROM c INTO @Schema, @Object, @Type, @PropName, @PropValue;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID(QUOTENAME(@Schema) + N'.' + QUOTENAME(@Object)) IS NULL
        SET @Skipped += 1;
    ELSE
    BEGIN
        SET @Current = NULL;
        SELECT @Current = CONVERT(nvarchar(4000), value)
        FROM sys.fn_listextendedproperty(@PropName, N'SCHEMA', @Schema, @Type, @Object, NULL, NULL);

        IF @Current IS NULL
        BEGIN
            EXEC sys.sp_addextendedproperty @name = @PropName, @value = @PropValue,
                 @level0type = N'SCHEMA', @level0name = @Schema,
                 @level1type = @Type,     @level1name = @Object;
            SET @Added += 1;
        END
        ELSE IF @Current <> @PropValue
        BEGIN
            EXEC sys.sp_updateextendedproperty @name = @PropName, @value = @PropValue,
                 @level0type = N'SCHEMA', @level0name = @Schema,
                 @level1type = @Type,     @level1name = @Object;
            SET @Updated += 1;
        END
        ELSE
            SET @Unchanged += 1;
    END;
    FETCH NEXT FROM c INTO @Schema, @Object, @Type, @PropName, @PropValue;
END
CLOSE c;
DEALLOCATE c;

PRINT CONCAT(N'Extended properties: ', @Added, N' added, ', @Updated, N' updated, ',
             @Unchanged, N' unchanged, ', @Skipped, N' skipped (object not present).');
GO

'@

function New-Metadata($Objs) {
    $rows = @($Objs | Where-Object { $Level1Type.ContainsKey($_.ObjectType) })
    $vals = ($rows | ForEach-Object {
        $tp = if ($_.IsThirdParty) { 'True' } else { 'False' }
        '    ({0}, {1}, {2}, {3}, {4}, {5})' -f `
            (ConvertTo-SqlString $_.Schema),
            (ConvertTo-SqlString $_.ObjectName),
            (ConvertTo-SqlString $Level1Type[$_.ObjectType]),
            (ConvertTo-SqlString $_.RepositoryGroup),
            (ConvertTo-SqlString $_.PackageName),
            (ConvertTo-SqlString $tp)
    }) -join ",`n"
    return $MetadataTemplate.Replace('__RULE__', $HeaderRule).Replace('__VALS__', $vals)
}

$FindRefsTemplate = @'
__RULE__
-- find_old_name_references.sql  (GENERATED from 10_metadata/rename_map.csv)
-- DIAGNOSTIC - not part of any deploy script.
--
-- Run BEFORE the rename migration. Lists SQL Agent job steps (msdb) and module
-- definitions in the current database that still mention a pre-rename name.
-- Agent steps, application code and linked-server queries are NOT updated by the repo.
__RULE__
SET NOCOUNT ON;
DECLARE @Old TABLE (OldName sysname NOT NULL);
INSERT @Old (OldName) VALUES
__VALS__;

SELECT 'AgentJobStep' AS FoundIn, j.name AS JobName, s.step_id, s.step_name, o.OldName
FROM msdb.dbo.sysjobsteps AS s
JOIN msdb.dbo.sysjobs AS j ON j.job_id = s.job_id
JOIN @Old AS o ON s.command LIKE N'%' + REPLACE(o.OldName, N'_', N'~_') + N'%' ESCAPE N'~'
ORDER BY j.name, s.step_id;

SELECT 'Module' AS FoundIn, OBJECT_SCHEMA_NAME(m.object_id) + N'.' + OBJECT_NAME(m.object_id) AS ObjectName, o.OldName
FROM sys.sql_modules AS m
JOIN @Old AS o ON m.definition LIKE N'%' + REPLACE(o.OldName, N'_', N'~_') + N'%' ESCAPE N'~'
ORDER BY 2, 3;
GO

'@

function New-FindReferences($RenameRows) {
    $vals = ($RenameRows | ForEach-Object { '    (' + (ConvertTo-SqlString $_.OldName) + ')' }) -join ",`n"
    return $FindRefsTemplate.Replace('__RULE__', $HeaderRule).Replace('__VALS__', $vals)
}

# ---------------------------------------------------------------- main

$loaded = Import-Manifest
$objs = $loaded[0]
$pkgs = $loaded[1]
$renameRows = Read-Csv $Renames
$migs = Import-Migrations $objs
$refs = Import-ReferenceData $objs

Write-TextFile (Join-Path $Root 'tools\find_old_name_references.sql')  (New-FindReferences $renameRows)
Write-TextFile (Join-Path $Root '09_deployment\deploy_all.sql')        (New-DeployAll $objs $migs $refs)
Write-TextFile (Join-Path $Root '09_deployment\deploy_third_party.sql') (New-ThirdParty $objs)
foreach ($p in $pkgs) {
    Write-TextFile (Join-Path $Root "09_deployment\packages\$($p.ScriptName).sql") (New-Package $p $objs $migs $refs)
}
Write-TextFile (Join-Path $Root '10_metadata\apply_extended_properties.sql') (New-Metadata $objs)

$missingFiles = @($objs | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Root $_.RepoPath) -PathType Leaf) } |
                  ForEach-Object { $_.RepoPath })
if ($missingFiles.Count -gt 0) {
    throw ("Manifest points at missing files:`n  " + ($missingFiles -join "`n  "))
}

Write-Host "Generated deploy_all, deploy_third_party, $($pkgs.Count) package scripts and metadata for $($objs.Count) objects, $($migs.Count) migrations and $($refs.Count) reference data scripts."

