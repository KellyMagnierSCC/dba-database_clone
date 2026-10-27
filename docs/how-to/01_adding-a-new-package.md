# How to add a new deployment package

A **package** is a named group of objects that can be deployed on its own with one script, for example `09_deployment/packages/deploy_scc_cpu.sql`. Packages sit on top of the domain folders. A package can use objects from several domains, and the folder an object lives in does not change because of the package it belongs to.

Think of the domain folders as the aisles in a warehouse and a package as an order list. The list says which items to pick, but the items stay on their shelves.

You never write a package script by hand. You describe the package in two CSV files, and the generator writes the script.

| File | What you put in it |
|---|---|
| `10_metadata/packages.csv` | One row for the package: its name, script name, vendor requirements and description |
| `10_metadata/object_manifest.csv` | One row per object, with the `PackageName` column set to the new package |
| `09_deployment/packages/deploy_<name>.sql` | **Generated. Do not edit.** |

---

## Worked example

This example adds a package called **`SCC_Performance - Query Monitoring`**. It captures the top queries from the plan cache into a history table. It has three objects:

| Object | Type | File |
|---|---|---|
| `Query_TopQueries_History` | Table | `04_tables/query/Query_TopQueries_History.sql` |
| `vw_Query_TopQueries_Latest` | View | `05_views/query/vw_Query_TopQueries_Latest.sql` |
| `usp_Monitor_CaptureTopQueries` | Procedure | `06_programmability/procedures/query/usp_Monitor_CaptureTopQueries.sql` |

### Step 1: Create a branch

```
git checkout main
git pull
git checkout -b feature/package-query-monitoring
```

### Step 2: Pick the names

| Item | Convention | Example |
|---|---|---|
| `PackageName` | `SCC_<Area> - <Plain description>` | `SCC_Performance - Query Monitoring` |
| `ScriptName` | `deploy_scc_<short_name>`, lower case, no `.sql` | `deploy_scc_query` |

`PackageName` has to match **exactly**, letter for letter and including spaces, everywhere it appears. That means `packages.csv`, every row in `object_manifest.csv`, and the `PackageName` extended property that gets stamped on each object. A single typo leaves you with an object that belongs to no package, or a package that has no objects, and the generator stops with the error `Package has no objects`.

### Step 3: Write the object files

Each object gets its own file, named after the object and placed in its type and domain folder. Use the domain guide (`docs/DBA_DomainReferenceGuide.docx`) to choose the domain. For the file templates (table guard, `CREATE OR ALTER`, encoding), see [02_adding-objects-to-a-package.md](02_adding-objects-to-a-package.md#step-2-write-the-file).

### Step 4: Add the package row to `packages.csv`

```csv
SCC_Performance - Query Monitoring,deploy_scc_query,,Top query capture from the plan cache and latest-run view.
```

The columns are `PackageName,ScriptName,ThirdPartyRequires,Description`.

- **ThirdPartyRequires** lists vendor objects the package needs. Use the `ObjectName` values from the manifest's third-party rows, separated by semicolons with no spaces, for example `sp_WhoIsActive` or `Install-All-Scripts`. Leave it empty if the package doesn't call vendor code.
- If **Description** contains a comma, put it in double quotes.

### Step 5: Add one manifest row per object to `object_manifest.csv`

```csv
Table,dbo,Query_TopQueries_History,04_tables/query/Query_TopQueries_History.sql,query,SCC_Performance - Query Monitoring,FALSE,,,525
View,dbo,vw_Query_TopQueries_Latest,05_views/query/vw_Query_TopQueries_Latest.sql,query,SCC_Performance - Query Monitoring,FALSE,,Query_TopQueries_History,935
Procedure,dbo,usp_Monitor_CaptureTopQueries,06_programmability/procedures/query/usp_Monitor_CaptureTopQueries.sql,query,SCC_Performance - Query Monitoring,FALSE,,Query_TopQueries_History,1150
```

| Column | Rule |
|---|---|
| `ObjectType` | `Table`, `View` or `Procedure` |
| `Schema` | Always `dbo` |
| `RepoPath` | Forward slashes, relative to the repo root, and must point at a file that exists |
| `RepositoryGroup` | The domain, which is the same as the folder name |
| `IsThirdParty` | `FALSE` for our own code |
| `Vendor` | Empty for our own code |
| `DependsOn` | Semicolon-separated `ObjectName`s this object reads or calls |
| `DeployOrder` | A number higher than every object listed in `DependsOn` |

**How deploy order works.** The deploy scripts always run tables first, then views, then procedures. `DeployOrder` only decides the order **within** each of those groups. As a rough guide, tables currently use 310–520, views 530–1070 and procedures 1080–1140. Leave gaps so the next person can slot objects in between.

**Why `DependsOn` matters.** The package script includes the package's own objects **plus everything they depend on, even objects owned by other packages**. If your view reads `CPU_Utilisation_History`, list it in `DependsOn`, and the generator will add that table to your package script so the package can deploy on an empty database. A dependency you leave out will deploy fine in your test environment, where the table already exists, and then fail on a fresh server.

### Step 6: Run the generator

From the repository root:

```powershell
.\tools\generate_deploy.ps1
```

The generator:

- writes `09_deployment/packages/deploy_scc_query.sql`
- adds the three objects to `09_deployment/deploy_all.sql`
- adds them to `10_metadata/apply_extended_properties.sql`

It stops with an error if a `RepoPath` points at a missing file, a `DependsOn` name isn't in the manifest, or the package has no objects.

### Step 7: Review the generated script

Open `09_deployment/packages/deploy_scc_query.sql` and check:

- The header shows `Own objects: 3`.
- `Pulled from other packages:` lists only the objects you expected.
- The `:r` lines run in the right order: tables, then views, then procedures.

Run `git diff` as well. The only changes should be your new files, the two CSVs and the generated scripts. If other deploy scripts changed in ways you didn't expect, stop and find out why before going further.

### Step 8: Test on a non-production instance

```
sqlcmd -S <dev-instance> -E -b -v RepoRoot="<repo path>" DatabaseName="<database>" -i 09_deployment\packages\deploy_scc_query.sql
```

Run it **twice**. The second run must succeed with no errors, which proves the scripts can be re-run safely. Then confirm the metadata was stamped:

```sql
SELECT OBJECT_NAME(major_id) AS ObjectName, name, value
FROM sys.extended_properties
WHERE class = 1 AND name = N'PackageName' AND value = N'SCC_Performance - Query Monitoring';
```

If the package needs an Agent job to schedule the procedure, add the job definition under `07_jobs/definitions/`. Jobs are not deployed by the package scripts.

### Step 9: Commit and raise a pull request

```
git add 04_tables/query 05_views/query 06_programmability/procedures/query 10_metadata 09_deployment
git commit -m "Add SCC_Performance - Query Monitoring package"
git push -u origin feature/package-query-monitoring
```

---

## Moving existing objects into a new package

An object belongs to exactly one package. To move one, change the `PackageName` in its manifest row and re-run the generator. **Do not move the file**, because its domain folder stays the same. The next deployment updates the `PackageName` extended property on that object.

## Checklist

- [ ] Object files created in the correct type and domain folders
- [ ] Package row added to `packages.csv`
- [ ] One manifest row per object, with `PackageName` matching exactly
- [ ] `DependsOn` filled in, and `DeployOrder` above every dependency
- [ ] `.\tools\generate_deploy.ps1` run, and the generated files committed
- [ ] Package script run twice on a non-production instance without errors
