<!-- Change to an existing view or procedure (no table changes). Guide: docs/how-to/03_changing-existing-objects-and-migrations.md, Part A.
     If a table changes too, use ?template=table_migration.md instead.
     Checklists: tick only what you did. If an item doesn't apply, leave it unticked and write why on the same line.
     CREATE OR ALTER, USE, [dbo], file names and generated files are checked automatically: see the PR's checks, not this list. -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Object(s) changed

| Object | Type | Package |
|---|---|---|
| | | |

Ticket:

## What changed and why

<!-- Behaviour before -> after. Reviewers can see the old version in the diff; explain the reason here. -->

**Does behaviour change?** <!-- Yes or No. "No" means a refactor, standards fix or comment change: say which. -->

## Who or what uses it

<!-- Agent jobs, reports, dashboards or other views and procedures that use this object. Will any of them see a difference? -->

- [ ] Searched the repo, `sys.sql_modules` and `msdb.dbo.sysjobsteps` for references
- [ ] What it returns or writes (columns, types, target tables) is unchanged, **or** every consumer has been updated in this PR or is listed above

## Checklist

- [ ] If it now reads or calls something new: `DependsOn` updated and `.\tools\generate_deploy.ps1` run

## Testing

| Instance | Database | Branch commit |
|---|---|---|
| | | |

- [ ] Package script run **twice** in your own test database on a non-production instance without errors
- [ ] If this fixes a reported problem: reproduced on `main` first, then shown fixed on the branch
- [ ] If behaviour changes: output compared before and after. If not: object run once to confirm it still works

<!-- Paste the output or describe the results. -->

## Deployment record

<!-- Servers deployed from main after merge. Testing in your own database goes under Testing, not here. -->

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

<!-- Usually: revert this PR's commit (git revert) and redeploy the package; the previous definition is in the file's Git history.
     If this change fixed a bug, say what reverting would bring back. -->
