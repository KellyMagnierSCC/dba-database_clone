<!-- New deployment package. Guide: docs/how-to/01_adding-a-new-package.md
     Checklists: tick only what you did. If an item doesn't apply, leave it unticked and write why on the same line. -->

Closes #<!-- issue number: links this PR to the issue and closes the issue when the PR is merged -->

## Package

| | |
|---|---|
| PackageName | `SCC_<Area> - <Description>` |
| Script | `09_deployment/packages/deploy_scc_<name>.sql` |
| Vendor requirements | <!-- e.g. sp_WhoIsActive, or none --> |
| Ticket | |

## What it does and why

<!-- What does the package monitor or do, and who asked for it? -->

## Objects

| Object | Type | Domain | Depends on |
|---|---|---|---|
| | | | |

**Objects pulled in from other packages** (copy from the generated script header):

## Checklist

- [ ] Object files are in `<type>/<domain>/`, named after the object, and started from `tools/templates/`
- [ ] Row added to `10_metadata/packages.csv`
- [ ] One `10_metadata/object_manifest.csv` row per object, with `PackageName` matching exactly
- [ ] `DependsOn` filled in, and `DeployOrder` higher than every dependency
- [ ] `.\tools\generate_deploy.ps1` run, and all generated files committed
- [ ] Generated script header shows the expected `Own objects` count, with nothing unexpected in `Pulled from other packages`
- [ ] Any Agent job added to `07_jobs/definitions/`, with steps that only `EXEC` procedures

## Testing

- [ ] Package script run on an empty database (proves the dependencies are complete)
- [ ] Package script run a second time without errors (proves it can be re-run)
- [ ] `PackageName` extended property present on every object

<!-- Paste the sqlcmd output or a summary. -->

## Deployment record

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

<!-- A new package only adds objects. To remove it, write a migration that drops the package's objects, remove their manifest rows and package row, and regenerate. -->
