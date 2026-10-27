# How to add a new SQL object to an existing package

Use this guide when you add a **new** table, view or procedure to a package that already exists. To change an object that already exists, see [03_changing-existing-objects-and-migrations.md](03_changing-existing-objects-and-migrations.md).

There are three steps: **write the file, register it in the manifest, and regenerate.** A file that isn't in `object_manifest.csv` is never deployed, because the deploy scripts only include what the manifest lists.

---

## Worked example

This example adds a view called `vw_CPU_Utilisation_Daily` to the existing package **`SCC_Performance - CPU Monitoring`**. The view reads `CPU_Utilisation_History`.

### Step 1: Choose the domain and name

- **Domain:** use the domain of the object's *subject*, as defined in `docs/DBA_DomainReferenceGuide.docx`. This view is about CPU, so it goes in `cpu`.
- **Name:** follow `docs/naming-conventions.pdf`.

  | Type | Name pattern |
  |---|---|
  | View | `vw_<Domain>_<Description>` |
  | Procedure | `usp_<Domain>_<VerbNoun>` (capture procedures use `usp_Monitor_Capture<Thing>`) |
  | Table | `<Domain>_<Thing>` (history tables end in `_History`) |

- **File:** one object per file, named exactly after the object: `05_views/cpu/vw_CPU_Utilisation_Daily.sql`.

### Step 2: Write the file

The quickest way to start is to copy a template from `tools/templates/` (`table.sql`, `view.sql` or `procedure.sql`). Rename the copy to the object name, find-and-replace the placeholder name, add your code, and delete the template's header block.

Every object file follows these rules:

- It starts with `SET ANSI_NULLS ON` and `SET QUOTED_IDENTIFIER ON`.
- It contains **no `USE` statement**, because the deploy script selects the database.
- Objects are always schema-qualified as `[dbo].`.
- It can be run more than once without errors.
- It is saved as UTF-8. Line endings are converted to CRLF for you by `.gitattributes`.

**View or procedure.** Use `CREATE OR ALTER`:

```sql
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_CPU_Utilisation_Daily]
AS
SELECT
    CAST(EventTime AS date)  AS EventDate,
    AVG(SQLProcessCPU)       AS AvgSQLProcessCPU,
    MAX(SQLProcessCPU)       AS MaxSQLProcessCPU,
    AVG(OtherProcessCPU)     AS AvgOtherProcessCPU
FROM dbo.CPU_Utilisation_History
GROUP BY CAST(EventTime AS date);
GO
```

**Table.** Wrap the table in an existence guard, give every constraint a name, and put indexes and defaults inside the same guard:

```sql
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[CPU_Scheduler_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[CPU_Scheduler_History](
    [RecordID]       [int] IDENTITY(1,1) NOT NULL,
    [SchedulerID]    [int] NOT NULL,
    [RunnableTasks]  [int] NOT NULL,
    [CaptureDate]    [datetime] NOT NULL,
 CONSTRAINT [PK_CPU_Scheduler_History] PRIMARY KEY CLUSTERED ([RecordID] ASC)
) ON [PRIMARY];
ALTER TABLE [dbo].[CPU_Scheduler_History] ADD CONSTRAINT [DF_CPU_Scheduler_History_CaptureDate] DEFAULT (sysutcdatetime()) FOR [CaptureDate];
END
GO
```

The guard means that **re-running a table file never changes an existing table.** That keeps redeployment safe, but it also means editing this file later does nothing on a server where the table already exists. That is what migrations are for, as covered in guide 03.

**Reading another domain's objects.** If a view or procedure reads objects from a different domain, add a comment at the top that says so:

```sql
-- Cross-domain: reads dbo.WaitStats_History (waitstats)
```

### Step 3: Add the manifest row

Add a row to `10_metadata/object_manifest.csv`. Copy `PackageName` exactly from an existing row of that package:

```csv
View,dbo,vw_CPU_Utilisation_Daily,05_views/cpu/vw_CPU_Utilisation_Daily.sql,cpu,SCC_Performance - CPU Monitoring,FALSE,,CPU_Utilisation_History,665
```

- **DependsOn:** `CPU_Utilisation_History`, the table the view reads. List every object that this object reads or calls.
- **DeployOrder:** `665`. Deploy order only applies within one type, so this number only has to be higher than any other *view* it depends on. Here it sits after the existing CPU views (610–660). If you add a procedure that reads this view, that procedure's `DependsOn` should include `vw_CPU_Utilisation_Daily`.

If the dependency is owned by another package, list it anyway. The generator will add it to this package's script automatically, and the script header will show it under `Pulled from other packages`.

### Step 4: Regenerate

From the repository root:

```powershell
.\tools\generate_deploy.ps1
```


Then check `git diff`. You should see these changes:

| File | Expected change |
|---|---|
| `09_deployment/packages/deploy_scc_cpu.sql` | One new `:r` line, and `Own objects` goes up by 1 |
| `09_deployment/deploy_all.sql` | One new `:r` line in the `05_views` section |
| `10_metadata/apply_extended_properties.sql` | One new row in the `VALUES` list |

### Step 5: Test and commit

```
sqlcmd -S <dev-instance> -E -b -v RepoRoot="<repo path>" DatabaseName="DBA_<yourname>" -i 09_deployment\packages\deploy_scc_cpu.sql
```

Run it twice, then raise a pull request. The pull request should contain the new object file, the manifest change, and the regenerated scripts.

---

## Adding a procedure that an Agent job calls

The procedure holds the logic. The job only does the scheduling, so its step should be a single `EXEC dbo.usp_...` call. Add the procedure as described above, then add or update the job definition in `07_jobs/definitions/`. The deploy scripts do not deploy jobs.

## Checklist

- [ ] File named after the object and placed in `<type>/<domain>/`
- [ ] Views and procedures use `CREATE OR ALTER`; tables use an `IF OBJECT_ID(...) IS NULL` guard with named constraints
- [ ] No `USE` statement; objects schema-qualified with `[dbo]`
- [ ] Manifest row added, with `PackageName` copied exactly, `DependsOn` filled in, and `DeployOrder` after its dependencies
- [ ] Cross-domain comment added if needed
- [ ] Generator run, and the diff shows only the expected changes
- [ ] Package script run twice in your own test database on a non-production instance
