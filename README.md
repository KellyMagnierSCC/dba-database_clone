# DBA database

Source-controlled definition of the DBA utility database. The repository is authoritative: the live database reflects it, not the other way round. Rationale for every structural choice is in [`docs/design-principles.pdf`](docs/design-principles.pdf).

**Schema:** all objects deploy to `[dbo]`. The folder structure carries the logical organisation instead.

## Structure

Top-level folders are numbered in deployment order; the domain subfolders are for navigation.

```
00_database/        01_create_database.sql       CREATE DATABASE + settings (environment-specific)
01_security/        01_users_roles.sql           roles, users, service accounts
02_third_party/<vendor>/                         adam_machanic, brent_ozar, ola_hallengren, erik_darling - never edited or renamed
03_types/                                        TVPs (none yet)
04_tables/<domain>/                              tables
05_views/<domain>/                               views
06_programmability/
    functions/
    procedures/<domain>/                         usp_* procedures
07_jobs/            definitions/  alerts/  _pending_migration/
08_migrations/                                   forward-only, dated structural change scripts
09_deployment/      config.sql  local_deploy.example.sql  deploy_all.sql  deploy_third_party.sql  packages/
10_metadata/        object_manifest.csv  packages.csv  migration_manifest.csv  rename_map.csv  apply_extended_properties.sql
tools/              generate_deploy.ps1  find_old_name_references.sql  workload_metrics/  templates/
docs/               design principles, naming conventions, domain guide, object naming reference, source control design
.github/            issue and pull request templates, CODEOWNERS (DevOps Team reviews every change)
CONTRIBUTING.md                                  first-time setup and the rules that matter most
```

One object per file, named after the object (`usp_Monitor_CaptureWaitStats.sql`). Domains are defined in [`docs/DBA_DomainReferenceGuide.docx`](docs/DBA_DomainReferenceGuide.docx); deployment and automation are in [`docs/DBA_SourceControl_Automation_Design.docx`](docs/DBA_SourceControl_Automation_Design.docx); names and prefixes in [`docs/naming-conventions.pdf`](docs/naming-conventions.pdf) and [`docs/DBA_ObjectNamingReference_v5.docx`](docs/DBA_ObjectNamingReference_v5.docx).

## Deploying

Nothing about a particular machine, server or database is stored in the repo. Every deployment supplies these values:

| Variable | What | Needed by |
|---|---|---|
| `RepoRoot` | Full path of your clone of this repository. It must not contain spaces, because the `:r` paths are unquoted (SSMS does not expand variables inside a quoted path) | Every deploy script |
| `DatabaseName` | The database to deploy into, e.g. `DBA` | Every deploy script |
| `DataPath`, `LogPath` | Data and log file folders, used only if the database has to be created | `deploy_all.sql` |

If any of these is missing, the deployment stops in `09_deployment/config.sql` with *"variable is not defined"*, before anything has been changed.

**sqlcmd**, from any folder:

```
sqlcmd -S <instance> -E -b -v RepoRoot="D:\DevOps\dba-database" DatabaseName="DBA" DataPath="E:\MOUNT\Databases\Data\Data01" LogPath="E:\MOUNT\Databases\Logs\Log01" -i 09_deployment\deploy_all.sql   # full deployment: folders 00-06 plus 08_migrations
sqlcmd -S <instance> -E -b -v RepoRoot="D:\DevOps\dba-database" DatabaseName="DBA" -i 09_deployment\deploy_third_party.sql         # vendor code on its own
sqlcmd -S <instance> -E -b -v RepoRoot="D:\DevOps\dba-database" DatabaseName="DBA" -i 09_deployment\packages\deploy_scc_cpu.sql    # one package
```

(The `-i` path is relative to the current folder. Run it from the repo root as shown, or give a full path.)

**SSMS:** copy `09_deployment/local_deploy.example.sql` to `09_deployment/local_deploy.sql`, which git ignores. Set your values and uncomment the deploy script you want. Then open it in SSMS, connected to the target server, turn on **Query → SQLCMD Mode**, and run it. Don't edit the generated deploy scripts.

Tables are created only if missing; views and procedures use `CREATE OR ALTER`; the database script applies its options on creation only. Object files contain no `USE`, so always run them through a deploy script or after selecting the target database.

Changing an existing table needs a migration in `08_migrations/` - re-running `CREATE TABLE` does nothing. Migrations are listed in `10_metadata/migration_manifest.csv` and run by the deploy scripts after `04_tables` and before `05_views`; `deploy_all.sql` runs them all, a package script runs those for its tables. Each run is logged in `dbo.Migration_History`. See [docs/how-to/03](docs/how-to/03_changing-existing-objects-and-migrations.md).

## Metadata

`10_metadata/object_manifest.csv` is the source of truth for placement and ordering; `apply_extended_properties.sql` stamps it onto the objects so the live database can be audited against the repo. Each table, view and procedure carries:

| Property | Value |
|---|---|
| `RepositoryGroup` | the object's domain (= its folder name), or the vendor folder |
| `PackageName` | optional deployment package (see `packages.csv`) |
| `IsThirdParty` | `True` / `False` |

After editing the CSVs or moving a file, run `powershell tools/generate_deploy.ps1`.

## Adding an object

Decide the domain with the quick reference in the domain guide, then: add the file under the type/domain folder (tables: `IF OBJECT_ID(...) IS NULL` guard; views/procs: `CREATE OR ALTER`); add a row to `object_manifest.csv` with its `DependsOn` and a `DeployOrder` after its dependencies; run the generator. If a view or procedure reads another domain's objects, add a header comment saying so.

## How-to guides

New to this repository? Start with [CONTRIBUTING.md](CONTRIBUTING.md), which covers what to install and set up before your first change.

- [Working in GitHub: issue → branch → pull request → deploy](docs/how-to/00_github-workflow.md) - start here
- [Adding a new deployment package](docs/how-to/01_adding-a-new-package.md)
- [Adding a new object to an existing package](docs/how-to/02_adding-objects-to-a-package.md)
- [Starter templates for tables, views, procedures and migrations](tools/templates/README.md)
- [Changing existing objects and using `08_migrations`](docs/how-to/03_changing-existing-objects-and-migrations.md), with a worked example of adding a column
- Pull request templates for each change type are in [`.github/PULL_REQUEST_TEMPLATE/`](.github/PULL_REQUEST_TEMPLATE/). Pick one by adding `?template=table_migration.md` (etc.) to the URL of the pull request page.

## Known deviations from the documents

- **`SqlServerVersions` and `CommandLog`** stay in `02_third_party/` under their published names. The naming reference lists them under `infrastructure` (and proposes renaming `SqlServerVersions` to `Instance_SqlServerVersions`), which conflicts with the third-party isolation principle and would break `sp_Blitz`.
- **`05_views/admin/`** holds the two `vw_Admin_*` views. The naming reference uses an `admin` group but the domain guide does not define it.
- **`cpu` tables and procedures:** `CPU_Utilisation_History` and `usp_Monitor_CaptureCpuUtilisation` sit in the `cpu` domain although the guide describes it as views only; the guide says to assess persistent CPU history case by case.
- **`Alert` procedure prefix** (`usp_Alert_<Condition>`, e.g. `usp_Alert_HighCpu`) is not yet in `naming-conventions.pdf` or the naming reference, which list Monitor, Jobs, Report and Diag. Definition: an `Alert` procedure evaluates a condition and notifies someone (for example by Database Mail) and does not persist data. `Monitor` procedures capture data and write history. A procedure that would do both is split into a `usp_Monitor_Capture...` procedure and a `usp_Alert_...` procedure that reads its table. The verb is omitted because `Alert` already implies it, as in `usp_Report_DatabaseSizing`.
- **`usp_Run_Blitz`** does not follow `usp_<Domain>_<VerbNoun>`; it is not in the naming reference and has not been renamed.
- **Deployment packages** (`packages.csv`) are an optional layer on top of the domains and are not described in the design documents. What a package is, and when to create one, is defined in [docs/how-to/01](docs/how-to/01_adding-a-new-package.md#what-a-package-is).
- Constraint and index names (for example `PK_BlitzRun`) were not renamed.
