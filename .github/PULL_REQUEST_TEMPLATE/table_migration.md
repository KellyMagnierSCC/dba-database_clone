<!-- Change to an existing table using 08_migrations. Guide: docs/how-to/03_changing-existing-objects-and-migrations.md, Part B.
     Once merged, this migration runs on EVERY server at its next deployment. Review it with that in mind.
     Checklists: tick only what you did. If an item doesn't apply, leave it unticked and write why on the same line. -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Migration

| | |
|---|---|
| File | `08_migrations/YYYYMMDD_NN_<ObjectName>_<Change>.sql` |
| Table | |
| Package(s) that will run it | |
| Ticket | |

## What changed and why

<!-- e.g. add ServerName to CPU_Utilisation_History so history can be combined across instances. -->

## Impact on existing servers

| Question | Answer |
|---|---|
| Approximate row count / size of the table on the largest server | |
| Does it rewrite data or take long locks (type change, NOT NULL backfill, index build)? | |
| Does it need to run outside a capture job's schedule or a backup window? | |
| Can data be lost (drop, narrowing a type)? | |
| Is it a **table rename**? (If so, run it by hand before deploying; see the guide) | |

## Checklist

- [ ] Started from `tools/templates/migration.sql`, with the header fully filled in
- [ ] Guards check both that the **table is missing** and that the **change is already applied**, so every later deployment does nothing
- [ ] Constraints and indexes have explicit names
- [ ] The table file in `04_tables/` is updated to **the same end state** (same names, types, nullability and defaults)
- [ ] Views and procedures that use the changed columns are updated in this PR
- [ ] Row added to `10_metadata/migration_manifest.csv`
- [ ] `.\tools\generate_deploy.ps1` run. The migration appears in `deploy_all.sql` and in the expected package scripts, after the tables and before the views
- [ ] No vendor (`02_third_party`) objects touched

## Testing

In your own test database on a non-production instance, with the **old** table:

- [ ] First package deploy: the migration printed `Added` / `Applied`
- [ ] Second package deploy: the migration printed `Skipped`
- [ ] `dbo.Migration_History` shows both runs
- [ ] A fresh database built from `deploy_all.sql` has the same table definition as the upgraded one

<!-- Paste the PRINT output. -->

## Deployment record

<!-- Also recorded on each server in dbo.Migration_History. -->

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

<!-- Migrations are forward-only. Describe the follow-up migration that would undo this change, and whether undoing it loses data. -->
