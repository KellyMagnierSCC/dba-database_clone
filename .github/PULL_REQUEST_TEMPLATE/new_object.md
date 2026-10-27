<!-- New table, view or procedure in an existing package. Guide: docs/how-to/02_adding-objects-to-a-package.md -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Object(s)

| Object | Type | Domain | Package | Depends on |
|---|---|---|---|---|
| | | | | |

Ticket:

## What and why

<!-- What does the object return or do, and who uses it? -->

## Checklist

- [ ] Started from `tools/templates/`, with the placeholder name replaced everywhere and the template header deleted
- [ ] File is in `<type>/<domain>/` and named after the object, following `usp_<Domain>_<VerbNoun>` / `vw_<Domain>_<Description>` / `<Domain>_<Thing>`
- [ ] Table: has an `IF OBJECT_ID(...) IS NULL` guard and named constraints and indexes. View or procedure: uses `CREATE OR ALTER`
- [ ] No `USE` statement, and every object is qualified with `[dbo]`
- [ ] Cross-domain comment added if it reads another domain's objects
- [ ] `object_manifest.csv` row added, with `PackageName` copied exactly, `DependsOn` filled in and `DeployOrder` after its dependencies
- [ ] `.\tools\generate_deploy.ps1` run. The diff shows one new `:r` line in the package script and in `deploy_all.sql`, and one new metadata row

## Testing

- [ ] Package script run twice in your own test database on a non-production instance without errors
- [ ] Results checked (paste a sample or describe them)

## Deployment record

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

<!-- View or procedure: revert this PR and redeploy, or add a DROP migration. Table: a DROP TABLE migration (any data is lost). -->
