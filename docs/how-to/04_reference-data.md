# How to deploy standard rows with `11_reference_data`

Some tables hold configuration rather than history: the rows say *how the framework should behave*, and they should be the same on every server. `Scc_BaselineRule` (which sp_Blitz checks are mandatory) is one. These rows are kept in the repository and loaded by the same deploy scripts that create the tables.

- **`04_tables/`** defines the table's **structure**.
- **`11_reference_data/`** defines the table's **standard rows**.

## How it works

Each file in `11_reference_data/<domain>/` is named after the table it loads and contains one `MERGE` statement. The rows are written out in a `VALUES` list:

```sql
MERGE [dbo].[Scc_BaselineRule] AS t
USING (VALUES
    (1, 'Backups', 'Mandatory', 'Database', 'DBA', N'Databases must have recent backups'),
    ...
) AS s (CheckID, BaselineDomain, RequiredState, AppliesTo, OwnerTeam, Notes)
    ON t.CheckID = s.CheckID
WHEN MATCHED AND <something differs> THEN UPDATE ...
WHEN NOT MATCHED BY TARGET           THEN INSERT ...
WHEN NOT MATCHED BY SOURCE           THEN DELETE;
```

On every deployment the MERGE compares the table with the list and fixes whatever differs. It's like a stocktake: missing rows are added, changed rows are corrected and rows no longer on the list are removed. Running it again changes nothing, so it's safe in a re-runnable deployment.

The rows are stored as T-SQL, not as a CSV, because sqlcmd's `:r` only includes T-SQL. Loading a CSV would need `BULK INSERT`, which reads the file on the SQL Server machine as the service account, and that machine can't see your `RepoRoot`.

The deploy scripts run reference data **last**, after the procedures and before `apply_extended_properties.sql`. By then every table and migration is in place. Within that step, files run in the `DeployOrder` of their tables, so a parent table's rows load before a child's. `deploy_all.sql` runs every file; a package script runs the files for the tables it deploys.

## Tables owned by the repository, and tables shared with each server

**The repository owns the whole table** (`Scc_BaselineRule`): every row comes from the file, so the MERGE deletes any row that isn't in it. Rows added by hand on a server are removed at the next deployment.

**The table also holds rows added on each server** (`Scc_AcceptedRisk`): the standard accepted risks (the approved sysadmin logins) come from the repository, but a server can have its own as well. The table has an `IsStandard` column:

| `IsStandard` | Row comes from | The deployment |
|---|---|---|
| `1` | `11_reference_data/blitz_scc/Scc_AcceptedRisk.sql` | adds, changes and deletes it to match the file |
| `0` (the default) | added on the server | never changes or deletes it |

The MERGE deletes only rows with `IsStandard = 1`. If a server already has a local row with the same key as a standard row, the deployment takes it over and sets `IsStandard = 1`.

Add server-specific accepted risks directly on the server, without `IsStandard`:

```sql
INSERT dbo.Scc_AcceptedRisk (CheckID, ScopeType, ScopeName, ApprovedBy, ApprovalDate, ReviewByDate, Justification)
VALUES (4, 'Login', N'DOMAIN\SomeLocalLogin', N'<approver>', '2026-11-12', '2027-11-12', N'<why>');
```

## Changing the standard rows

1. Edit the `VALUES` list in the file.
2. Commit and open a pull request. The diff shows exactly which rules or exceptions changed, so a reviewer can see a new sysadmin exception before it reaches any server.
3. Deploy as usual (`deploy_all.sql` or the package script).

## Adding reference data for another table

1. Copy `tools/templates/reference_data.sql` to `11_reference_data/<domain>/<TableName>.sql`.
2. Write the MERGE, using the table's primary key in the `ON` clause. Choose clause A (the repository owns the table) or B (shared, with `IsStandard`) as described in the template.
3. Add a row to `10_metadata/reference_data_manifest.csv`:

   ```
   DataFile,ObjectName
   <domain>/<TableName>.sql,<TableName>
   ```

4. Run `.\tools\generate_deploy.ps1` and commit the regenerated deploy scripts with your change.

The generator stops with an error if a `.sql` file in `11_reference_data/` isn't listed, if a listed file doesn't exist, if the table isn't in `object_manifest.csv`, or if the file isn't named after its table. `tools\check_standards.ps1` (rule SC011) also checks that the file is a `MERGE` into the table it's named after and contains no `CREATE`, `ALTER` or `DROP`.

## What doesn't belong here

- **Anything specific to one server**, such as instance names, database names on a single server, or local logins. The repository stores nothing about a particular machine.
- **Structure.** New columns or constraints go in `04_tables`, plus a migration in `08_migrations` once the table exists on a server.
- **History or captured data.** That's what the monitoring procedures write.

## Checklist

- [ ] File in `11_reference_data/<domain>/`, named after the table, containing one `MERGE [dbo].[<Table>]`
- [ ] Row added to `10_metadata/reference_data_manifest.csv`, and `.\tools\generate_deploy.ps1` run
- [ ] `.\tools\check_standards.ps1` passes
- [ ] Deployed twice to a test server: the second run reports `0 inserted, 0 updated, 0 deleted`
