<#
.SYNOPSIS
    Checks object files and migrations against the repository's coding standards.

.DESCRIPTION
    Run from anywhere:  .\tools\check_standards.ps1
    Exit code 0 = no violations; 1 = violations (each printed as  path:line  RULE  message).

    Checks 03_types, 04_tables, 05_views, 06_programmability and 08_migrations.
    02_third_party (vendor code, never edited) and the generated files are not checked.

    Rules
      SC001  Views, procedures and functions use CREATE OR ALTER, never plain CREATE
      SC002  Tables are created inside an IF OBJECT_ID(N'[dbo].[<Table>]', N'U') IS NULL guard
      SC003  No USE statement (the database is chosen at deploy time)
      SC004  The object created has the same name as its file
      SC005  The object created is schema-qualified with [dbo]
      SC006  Every constraint is named: CONSTRAINT [<name>] before PRIMARY KEY, UNIQUE,
             FOREIGN KEY, CHECK and DEFAULT. System-generated names differ on every server
      SC007  No extended-property calls. Properties come from 10_metadata\apply_extended_properties.sql
      SC008  Object files and 10_metadata\object_manifest.csv agree: every file has a row, every
             row has a file, and ObjectName and RepositoryGroup match the file's name and folder
      SC009  Name prefixes: views vw_, procedures usp_, functions fn_, table types tvp_
      SC010  Migrations are named YYYYMMDD_NN_<ObjectName>_<Change>.sql and have the header
             lines "-- Migration : <file name>" and "-- Re-runnable:"
      SC000  An entry in tools\standards_exceptions.csv no longer matches a violation (remove it)

    Known exceptions are listed in tools\standards_exceptions.csv (Rule,Path,Reason). They are
    reported but don't fail the check. Fix the file, then delete its exception row.

    This is pattern matching, not a full T-SQL parser: comments and string contents are blanked
    out before the checks run, so commented-out code and text inside quotes are ignored.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root       = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$Manifest   = Join-Path $Root '10_metadata\object_manifest.csv'
$Exceptions = Join-Path $Root 'tools\standards_exceptions.csv'

$Violations = New-Object System.Collections.Generic.List[object]

function Add-Violation([string]$Rule, [string]$Path, [int]$Line, [string]$Message) {
    $Violations.Add([pscustomobject]@{ Rule = $Rule; Path = $Path; Line = $Line; Message = $Message })
}

function Get-LineNumber([string]$Text, [int]$Index) {
    if ($Index -le 0) { return 1 }
    return ([regex]::Matches($Text.Substring(0, $Index), "`n")).Count + 1
}

# Replaces comments (and, unless -KeepStrings, the contents of string literals) with spaces.
# Newlines are kept, so character positions and line numbers still match the original file.
function Get-CodeOnly([string]$Text, [switch]$KeepStrings) {
    $sb = New-Object System.Text.StringBuilder $Text.Length
    $i = 0
    $n = $Text.Length
    while ($i -lt $n) {
        $c = $Text[$i]
        $next = [char]0
        if ($i + 1 -lt $n) { $next = $Text[$i + 1] }

        if ($c -eq '-' -and $next -eq '-') {
            while ($i -lt $n -and $Text[$i] -ne "`n") { [void]$sb.Append(' '); $i++ }
        }
        elseif ($c -eq '/' -and $next -eq '*') {
            # T-SQL block comments nest
            $depth = 0
            while ($i -lt $n) {
                $a = $Text[$i]
                $b = [char]0
                if ($i + 1 -lt $n) { $b = $Text[$i + 1] }
                if ($a -eq '/' -and $b -eq '*') { $depth++; [void]$sb.Append('  '); $i += 2; continue }
                if ($a -eq '*' -and $b -eq '/') {
                    $depth--; [void]$sb.Append('  '); $i += 2
                    if ($depth -eq 0) { break }
                    continue
                }
                if ($a -eq "`n") { [void]$sb.Append("`n") } else { [void]$sb.Append(' ') }
                $i++
            }
        }
        elseif ($c -eq "'") {
            [void]$sb.Append("'")
            $i++
            while ($i -lt $n) {
                $a = $Text[$i]
                if ($a -eq "'") {
                    if ($i + 1 -lt $n -and $Text[$i + 1] -eq "'") {
                        if ($KeepStrings) { [void]$sb.Append("''") } else { [void]$sb.Append('  ') }
                        $i += 2
                        continue
                    }
                    break
                }
                if ($KeepStrings -or $a -eq "`n") { [void]$sb.Append($a) } else { [void]$sb.Append(' ') }
                $i++
            }
            if ($i -lt $n) { [void]$sb.Append("'"); $i++ }
        }
        else {
            [void]$sb.Append($c)
            $i++
        }
    }
    return $sb.ToString()
}

# Splits "[dbo].[Name]", "dbo.Name" or "[Name]" into schema and name
function Split-ObjectName([string]$Raw) {
    $parts = @($Raw -split '\s*\.\s*' | ForEach-Object { $_.Trim().Trim('[', ']') })
    if ($parts.Count -ge 2) { return @{ Schema = $parts[$parts.Count - 2]; Name = $parts[$parts.Count - 1] } }
    return @{ Schema = ''; Name = $parts[0] }
}

$NamePattern = '((?:\[[^\]]+\]|\w+)\s*\.\s*)?(\[[^\]]+\]|\w+)'

# ---------------------------------------------------------------- object files

$kinds = @(
    @{ Folder = '03_types';                       Kind = 'Type';      Prefix = 'tvp_' },
    @{ Folder = '04_tables';                      Kind = 'Table';     Prefix = '' },
    @{ Folder = '05_views';                       Kind = 'View';      Prefix = 'vw_' },
    @{ Folder = '06_programmability\procedures';  Kind = 'Procedure'; Prefix = 'usp_' },
    @{ Folder = '06_programmability\functions';   Kind = 'Function';  Prefix = 'fn_' }
)

$objectFiles = New-Object System.Collections.Generic.List[object]

foreach ($k in $kinds) {
    $dir = Join-Path $Root $k.Folder
    if (-not (Test-Path $dir)) { continue }
    foreach ($f in @(Get-ChildItem -Path $dir -Filter '*.sql' -Recurse -File)) {
        $rel = $f.FullName.Substring($Root.Length).TrimStart('\', '/').Replace('\', '/')
        $objectFiles.Add([pscustomobject]@{ Path = $rel; File = $f; Kind = $k.Kind; Prefix = $k.Prefix })
    }
}

foreach ($o in $objectFiles) {
    $raw   = [System.IO.File]::ReadAllText($o.File.FullName)
    $code  = Get-CodeOnly $raw
    $named = Get-CodeOnly $raw -KeepStrings
    $base  = [System.IO.Path]::GetFileNameWithoutExtension($o.File.Name)

    # SC003
    foreach ($m in [regex]::Matches($code, '(?im)^\s*USE\s+\S')) {
        Add-Violation 'SC003' $o.Path (Get-LineNumber $code $m.Index) 'USE statement. The database is chosen at deploy time'
    }

    # SC007
    foreach ($m in [regex]::Matches($code, '(?i)\bsp_(add|update|drop)extendedproperty\b')) {
        Add-Violation 'SC007' $o.Path (Get-LineNumber $code $m.Index) 'Extended-property call. These come from 10_metadata\apply_extended_properties.sql'
    }

    # SC009
    if ($o.Prefix -and -not $base.StartsWith($o.Prefix)) {
        Add-Violation 'SC009' $o.Path 1 "$($o.Kind) names start with $($o.Prefix)"
    }

    $createKeyword = @{ Type = 'TYPE'; Table = 'TABLE'; View = 'VIEW'; Procedure = 'PROC(?:EDURE)?'; Function = 'FUNCTION' }[$o.Kind]

    # SC001: no plain CREATE of a view, procedure, function or trigger anywhere in the file
    if ($o.Kind -in @('View', 'Procedure', 'Function')) {
        foreach ($m in [regex]::Matches($code, '(?i)\bCREATE\s+(VIEW|PROC|PROCEDURE|FUNCTION|TRIGGER)\b')) {
            Add-Violation 'SC001' $o.Path (Get-LineNumber $code $m.Index) "Plain CREATE $($m.Groups[1].Value.ToUpper()). Use CREATE OR ALTER"
        }
    }

    # The main CREATE statement: SC004, SC005
    $create = [regex]::Match($code, "(?i)\bCREATE\s+(?:OR\s+ALTER\s+)?$createKeyword\s+$NamePattern")
    if (-not $create.Success) {
        Add-Violation 'SC004' $o.Path 1 "No CREATE $($o.Kind.ToUpper()) statement found"
        continue
    }
    $line = Get-LineNumber $code $create.Index
    $obj  = Split-ObjectName ($create.Groups[1].Value + $create.Groups[2].Value)
    if ($obj.Name -cne $base) {
        Add-Violation 'SC004' $o.Path $line "Creates [$($obj.Name)] but the file is named $base.sql"
    }
    if ($obj.Schema -ne 'dbo') {
        Add-Violation 'SC005' $o.Path $line "Object is not schema-qualified as [dbo].[$($obj.Name)]"
    }

    if ($o.Kind -eq 'Table') {
        # SC002: the guard must name this table and come before the CREATE TABLE
        $guard = [regex]::Match($named, "(?is)\bIF\s+OBJECT_ID\s*\(\s*N?'$NamePattern'\s*,\s*N?'U'\s*\)\s+IS\s+NULL")
        if (-not $guard.Success) {
            Add-Violation 'SC002' $o.Path $line "CREATE TABLE is not inside an IF OBJECT_ID(N'[dbo].[$base]', N'U') IS NULL guard"
        } else {
            $g = Split-ObjectName ($guard.Groups[1].Value + $guard.Groups[2].Value)
            if ($g.Name -cne $base -or $guard.Index -gt $create.Index) {
                Add-Violation 'SC002' $o.Path (Get-LineNumber $named $guard.Index) "The IF OBJECT_ID guard must check [dbo].[$base] and come before CREATE TABLE"
            }
        }
    }

    $o | Add-Member -NotePropertyName Code -NotePropertyValue $code
}

# ---------------------------------------------------------------- SC006: named constraints

function Test-NamedConstraints([string]$Path, [string]$Code) {
    $keywords = '(?i)\b(PRIMARY\s+KEY|FOREIGN\s+KEY|UNIQUE|CHECK\s*\(|DEFAULT\s*\(|ADD\s+DEFAULT)'
    foreach ($m in [regex]::Matches($Code, $keywords)) {
        $kw = ($m.Groups[1].Value -replace '\s+', ' ').TrimEnd('(', ' ').ToUpper()
        $before = $Code.Substring([Math]::Max(0, $m.Index - 300), [Math]::Min(300, $m.Index))
        if ($kw -eq 'UNIQUE' -and $before -match '(?i)\bCREATE\s*$') { continue }   # CREATE UNIQUE INDEX
        if ($kw -eq 'ADD DEFAULT') {
            Add-Violation 'SC006' $Path (Get-LineNumber $Code $m.Index) 'Unnamed DEFAULT. Use ADD CONSTRAINT [DF_<Table>_<Column>] DEFAULT (...) FOR [<Column>]'
            continue
        }
        if ($before -notmatch '(?i)\bCONSTRAINT\s+(\[[^\]]+\]|\w+)\s*$') {
            Add-Violation 'SC006' $Path (Get-LineNumber $Code $m.Index) "Unnamed $kw. Put CONSTRAINT [<name>] in front of it"
        }
    }
}

foreach ($o in $objectFiles) {
    if ($o.Kind -eq 'Table' -and ($o.PSObject.Properties.Name -contains 'Code')) {
        Test-NamedConstraints $o.Path $o.Code
    }
}

# ---------------------------------------------------------------- migrations: SC003, SC006, SC007, SC010

$migDir = Join-Path $Root '08_migrations'
if (Test-Path $migDir) {
    foreach ($f in @(Get-ChildItem -Path $migDir -Filter '*.sql' -File)) {
        $rel  = '08_migrations/' + $f.Name
        $raw  = [System.IO.File]::ReadAllText($f.FullName)
        $code = Get-CodeOnly $raw
        $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)

        if ($f.Name -notmatch '^\d{8}_\d{2}_[A-Za-z0-9]+_\w+\.sql$') {
            Add-Violation 'SC010' $rel 1 'Migration file name must be YYYYMMDD_NN_<ObjectName>_<Change>.sql'
        }
        $header = [regex]::Match($raw, '(?im)^--\s*Migration\s*:\s*(\S+)')
        if (-not $header.Success -or $header.Groups[1].Value -ne $base) {
            Add-Violation 'SC010' $rel 1 "Header must contain the line '-- Migration : $base'"
        }
        if ($raw -notmatch '(?im)^--\s*Re-runnable\s*:') {
            Add-Violation 'SC010' $rel 1 "Header must contain a '-- Re-runnable:' line"
        }
        foreach ($m in [regex]::Matches($code, '(?im)^\s*USE\s+\S')) {
            Add-Violation 'SC003' $rel (Get-LineNumber $code $m.Index) 'USE statement. The database is chosen at deploy time'
        }
        foreach ($m in [regex]::Matches($code, '(?i)\bsp_(add|update|drop)extendedproperty\b')) {
            Add-Violation 'SC007' $rel (Get-LineNumber $code $m.Index) 'Extended-property call. These come from 10_metadata\apply_extended_properties.sql'
        }
        Test-NamedConstraints $rel $code
    }
}

# ---------------------------------------------------------------- SC008: files and manifest agree

$rows = @(Import-Csv -Path $Manifest -Encoding UTF8)
$byPath = @{}
foreach ($r in $rows) { $byPath[$r.RepoPath.Replace('\', '/')] = $r }

$objectFolders = '^(03_types|04_tables|05_views|06_programmability)/'
foreach ($r in $rows) {
    $p = $r.RepoPath.Replace('\', '/')
    if ($p -notmatch $objectFolders) { continue }
    if (-not (Test-Path (Join-Path $Root $p))) {
        Add-Violation 'SC008' '10_metadata/object_manifest.csv' 1 "Row for $($r.ObjectName) points at a missing file: $p"
    }
}

foreach ($o in $objectFiles) {
    if (-not $byPath.ContainsKey($o.Path)) {
        Add-Violation 'SC008' $o.Path 1 'Not in 10_metadata/object_manifest.csv, so it is never deployed'
        continue
    }
    $r = $byPath[$o.Path]
    $base = [System.IO.Path]::GetFileNameWithoutExtension($o.File.Name)
    if ($r.ObjectName -cne $base) {
        Add-Violation 'SC008' $o.Path 1 "Manifest ObjectName is $($r.ObjectName) but the file is named $base.sql"
    }
    $segments = $o.Path.Split('/')
    $domain = $null
    if ($segments[0] -in @('04_tables', '05_views') -and $segments.Count -ge 3) { $domain = $segments[1] }
    if ($segments[0] -eq '06_programmability' -and $segments[1] -eq 'procedures' -and $segments.Count -ge 4) { $domain = $segments[2] }
    if ($domain -and $r.RepositoryGroup -ne $domain) {
        Add-Violation 'SC008' $o.Path 1 "Manifest RepositoryGroup is $($r.RepositoryGroup) but the file is in the $domain folder"
    }
}

# ---------------------------------------------------------------- exceptions and report

$known = @()
if (Test-Path $Exceptions) { $known = @(Import-Csv -Path $Exceptions -Encoding UTF8) }

$failing = New-Object System.Collections.Generic.List[object]
$excused = New-Object System.Collections.Generic.List[object]
foreach ($v in $Violations) {
    $match = @($known | Where-Object { $_.Rule -eq $v.Rule -and $_.Path -eq $v.Path })
    if ($match.Count -gt 0) { $excused.Add($v) } else { $failing.Add($v) }
}
foreach ($e in $known) {
    $used = @($Violations | Where-Object { $_.Rule -eq $e.Rule -and $_.Path -eq $e.Path })
    if ($used.Count -eq 0) {
        $failing.Add([pscustomobject]@{ Rule = 'SC000'; Path = 'tools/standards_exceptions.csv'; Line = 1;
            Message = "Exception $($e.Rule) for $($e.Path) no longer applies. Delete that row" })
    }
}

foreach ($v in ($failing | Sort-Object Path, Line, Rule)) {
    Write-Host ("{0}:{1}  {2}  {3}" -f $v.Path, $v.Line, $v.Rule, $v.Message) -ForegroundColor Red
}
if ($excused.Count -gt 0) {
    Write-Host ''
    Write-Host "Known exceptions (tools\standards_exceptions.csv): $($excused.Count) violation(s) in $(@($excused | Select-Object -ExpandProperty Path -Unique).Count) file(s)"
}
Write-Host ''
Write-Host "Checked $($objectFiles.Count) object files and $(@(Get-ChildItem -Path $migDir -Filter '*.sql' -File -ErrorAction SilentlyContinue).Count) migrations: $($failing.Count) violation(s)."

if ($failing.Count -gt 0) { exit 1 }
exit 0
