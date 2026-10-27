<!-- Change to an existing view or procedure (no table changes). Guide: docs/how-to/03_changing-existing-objects-and-migrations.md, Part A.
     If a table changes too, use ?template=table_migration.md instead. -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Object(s) changed

| Object | Type | Package |
|---|---|---|
| | | |

Ticket:

## What changed and why

<!-- Behaviour before -> after. Reviewers can see the old version in the diff; explain the reason here. -->

## Who or what uses it

<!-- Agent jobs, reports, dashboards or other views and procedures that read this object. Will any of them see different columns or results? -->

- [ ] Searched `sys.sql_modules`, `07_jobs/` and the repo for references
- [ ] The column names and types it returns are unchanged, **or** every consumer has been updated in this PR or is listed above

## Checklist

- [ ] File edited in place, still using `CREATE OR ALTER` and the same file name
- [ ] If it now reads or calls something new: `DependsOn` updated and `.\tools\generate_deploy.ps1` run
- [ ] No `USE` statement, and every object is qualified with `[dbo]`

## Testing

- [ ] Package script run on a non-production instance
- [ ] Output compared before and after (describe or paste a sample)

## Deployment record

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

Revert this PR's commit (`git revert`) and redeploy the package. The previous definition is in the file's Git history.
