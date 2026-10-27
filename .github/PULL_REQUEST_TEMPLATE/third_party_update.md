<!-- New release of vendor code in 02_third_party/. Vendor files are replaced whole, never edited or renamed. -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Vendor update

| | |
|---|---|
| Vendor / tool | <!-- Ola Hallengren / Brent Ozar First Responder Kit / sp_WhoIsActive / Darling Data --> |
| File | `02_third_party/<vendor>/<file>.sql` |
| Version: old -> new | |
| Release notes link | |
| Ticket | |

## Why update

<!-- Bug fix, new SQL Server version support, a feature we need... -->

## Breaking changes in the release notes

<!-- Renamed or removed parameters, changed output columns, new prerequisites. Write "none" if there are none. -->

## Our code that depends on it

| Our object | Uses | Checked? |
|---|---|---|
| `usp_Run_Blitz` | `sp_Blitz` | |
| <!-- WhoIsActive capture procs / tables --> | `sp_WhoIsActive` output columns | |
| <!-- Agent jobs --> | Ola `DatabaseBackup` / `IndexOptimize` / `DatabaseIntegrityCheck` parameters | |

## Checklist

- [ ] File replaced with the vendor's published release, unchanged (no local edits)
- [ ] File name unchanged, or `object_manifest.csv` updated and `.\tools\generate_deploy.ps1` run
- [ ] If output columns changed: our capture tables are updated with a migration (use `?template=table_migration.md` for that part, or include it here)

## Testing

- [ ] `09_deployment\deploy_third_party.sql` run on a non-production instance
- [ ] Dependent packages deployed, and their capture procedures and jobs run once successfully

## Deployment record

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

Revert this PR's commit and run `deploy_third_party.sql` again to restore the previous release.
