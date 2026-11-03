<!-- New table, view or procedure in an existing package. Guide: docs/how-to/02_adding-objects-to-a-package.md
     Checklists: tick only what you did. If an item doesn't apply, leave it unticked and write why on the same line.
     CREATE OR ALTER, table guards, named constraints, USE, [dbo], file names, prefixes and generated files are
     checked automatically: see the PR's checks, not this list. -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Object(s)

| Object | Type | Domain | Package | Depends on |
|---|---|---|---|---|
| | | | | |

Ticket:

## What and why

<!-- What does the object return or do, and who uses it? -->

## Checklist

- [ ] Started from `tools/templates/`, with the placeholder name replaced everywhere (including constraint and index names) and the template header deleted
- [ ] Domain chosen from the domain guide, and the name follows `usp_<Domain>_<VerbNoun>` / `vw_<Domain>_<Description>` / `<Domain>_<Thing>`
- [ ] Cross-domain comment added if it reads another domain's objects
- [ ] `object_manifest.csv` row added, with `PackageName` copied exactly, `DependsOn` listing everything it reads or calls, and `DeployOrder` after its dependencies
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
