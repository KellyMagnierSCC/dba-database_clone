# How to change existing objects, and when to use `08_migrations`

The repository records two different things:

- **The object folders (`04`–`06`)** record **current state**: what each object looks like now.
- **`08_migrations/`** records **change**: the steps that take an existing database from its old state to its new one.

A useful analogy is a house. The object files are the architect's plan of the house as it should look today, and a builder can use that plan to build a new house from scratch. A migration is the renovation work order: *knock through this wall, add a window here*. You can't hand the plan to a family that already lives in the house and expect a new window to appear. You need the work order too. Every structural change needs **both**: the plan is updated so new houses get the window, and the work order changes the houses that already exist.

## Do I need a migration?

| Change | Edit the object file | Migration | Regenerate |
|---|---|---|---|
| Change a view's or procedure's logic | Yes | No | Only if `DependsOn` changes |
| Add a column to a table | Yes | **Yes** | **Yes** |
| Change a column's type, size or nullability | Yes | **Yes** | **Yes** |
| Rename a column | Yes, plus every view or procedure that uses it | **Yes** | **Yes** |
| Drop a column | Yes, plus every view or procedure that uses it | **Yes** | **Yes** |
| Add, change or drop an index or constraint | Yes | **Yes** | **Yes** |
| Backfill or correct data | No | **Yes** | **Yes** |
| Drop a whole object | Delete the file and its manifest row | **Yes** | **Yes** |
| Move an object to another package | No | No | **Yes** (change `PackageName` in the manifest) |
| Update vendor code | Replace the vendor file with the new release; never edit it | No | No |

**Why views and procedures don't need migrations.** They are deployed with `CREATE OR ALTER`, so every deployment replaces them completely with what is in the file. Tables are protected by `IF OBJECT_ID(...) IS NULL`, so once a table exists, re-running its file does nothing. That is safe, but it means **changes to an existing table only reach a live server through a migration.**

---

## Part A: Changing a view or procedure

1. Edit the file in place. Keep `CREATE OR ALTER` and keep the file name.
2. If the object now reads or calls something new, add that object to `DependsOn` in `10_metadata/object_manifest.csv` and run `.\tools\generate_deploy.ps1`.
3. Deploy the package from your branch into your own test database on a non-production instance, then raise a pull request. See "Test your branch in your own database" in [00_github-workflow.md](00_github-workflow.md).

```
sqlcmd -S <dev-instance> -E -b -v RepoRoot="<repo path>" DatabaseName="DBA_<yourname>" -i 09_deployment\packages\deploy_scc_cpu.sql
```

---

## Part B: Changing a table, worked example of adding a column

**Requirement:** add a `ServerName` column to `dbo.CPU_Utilisation_History` so that rows can be combined from several instances later. Existing rows should be filled in with the current server's name.

You change these files in one pull request:

| File | Why |
|---|---|
| `08_migrations/20261026_01_CPU_Utilisation_History_AddServerName.sql` | **New.** Adds the column on servers where the table already exists |
| `10_metadata/migration_manifest.csv` | **Edited.** Registers the migration so the deploy scripts run it |
| `04_tables/cpu/CPU_Utilisation_History.sql` | **Edited.** New servers get the column when the table is created |
| `05_views/cpu/vw_CPU_Utilisation_Hourly.sql` (optional) | **Edited.** Exposes the new column |

### Step 1: Write the migration

**File name:** `YYYYMMDD_NN_<ObjectName>_<Change>.sql`

- `YYYYMMDD` is the date you wrote the script. `NN` is a two-digit sequence for that day (`01`, `02`, …). Together they make the files sort in the order they must run.
- `<ObjectName>_<Change>` describes the change in PascalCase, for example `AddServerName`, `WidenQueryText` or `DropLegacyIndex`.

`08_migrations/20261026_01_CPU_Utilisation_History_AddServerName.sql`:

```sql
-- ============================================================================
-- Migration : 20261026_01_CPU_Utilisation_History_AddServerName
-- Author    : <your name>
-- Date      : 2026-10-26
-- Ticket    : <change / ticket ref>
-- Package   : SCC_Performance - CPU Monitoring
-- Purpose   : Add ServerName so CPU history can be combined across instances.
--             Existing rows are filled from the default.
-- Also changed: 04_tables/cpu/CPU_Utilisation_History.sql (current state)
-- Re-runnable: yes. Skips if the table is missing or the column already exists.
-- ============================================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'[dbo].[CPU_Utilisation_History]', N'U') IS NULL
    PRINT N'Skipped: dbo.CPU_Utilisation_History does not exist (it will be created with the column).';
ELSE IF COL_LENGTH(N'dbo.CPU_Utilisation_History', N'ServerName') IS NOT NULL
    PRINT N'Skipped: dbo.CPU_Utilisation_History.ServerName already exists.';
ELSE
BEGIN
    ALTER TABLE [dbo].[CPU_Utilisation_History]
        ADD [ServerName] [sysname] NOT NULL
            CONSTRAINT [DF_CPU_Utilisation_History_ServerName]
            DEFAULT (CONVERT(sysname, SERVERPROPERTY('ServerName')));

    PRINT N'Added dbo.CPU_Utilisation_History.ServerName.';
END
GO
```

Points to note:

- **There are two guards, and the second one matters most.** The deploy scripts run **every** migration on **every** deployment, so the "column already exists" check is what makes the second and later deployments do nothing. It also covers a brand-new server, where the table file has already created the table with the column by the time migrations run. The "table missing" check covers someone running the migration by hand against a database that doesn't have the table yet.
- **A NOT NULL column needs a default.** When you add a `NOT NULL` column with a default, SQL Server fills every existing row with that default. Without the default, the `ALTER` fails on any table that already has rows.
- **Name the constraint.** If you leave it out, SQL Server generates a name like `DF__CPU_Util__Serve__3B75D760`, which is different on every server and can't be targeted by a later migration.
- **No `USE` statement.** As with object files, you choose the database when you run the script.
- **Large tables.** Before adding a column with a default, rebuilding an index, or changing a column type on a big table, check the table's size and lock behaviour. Run the change outside the capture job's schedule.

### Step 2: Update the current-state table file

Edit `04_tables/cpu/CPU_Utilisation_History.sql` so that a new server builds the table with the column from the start:

```sql
IF OBJECT_ID(N'[dbo].[CPU_Utilisation_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[CPU_Utilisation_History](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[SQLProcessCPU] [int] NOT NULL,
	[SystemIdleCPU] [int] NOT NULL,
	[OtherProcessCPU] [int] NOT NULL,
	[CaptureDate] [datetime] NOT NULL,
	[ServerName] [sysname] NOT NULL,                                   -- added 20261026_01
 CONSTRAINT [PK_CPU_Utilisation_History] PRIMARY KEY CLUSTERED
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[CPU_Utilisation_History] ADD  CONSTRAINT [DF_CPU_Utilisation_History_CaptureDate]  DEFAULT (sysutcdatetime()) FOR [CaptureDate];
ALTER TABLE [dbo].[CPU_Utilisation_History] ADD  CONSTRAINT [DF_CPU_Utilisation_History_ServerName]  DEFAULT (CONVERT(sysname, SERVERPROPERTY('ServerName'))) FOR [ServerName];
END
GO
```

**The two routes must end in the same place.** An upgraded server, built from the old file plus the migration, and a new server, built from the new file, must have an identical table: the same column name, type, nullability, constraint name and default. Compare the two side by side before you commit. Any difference between them is a drift bug that will only show up months later.

### Step 3: Update anything that uses the table

- `usp_Monitor_CaptureCpuUtilisation` lists its `INSERT` columns explicitly, so the default fills `ServerName` and **the procedure needs no change**. That is one reason to always list columns in an `INSERT`.
- If a view should expose the new column, edit the view file. In this example that means adding `ServerName` to the `SELECT` and `GROUP BY` in `vw_CPU_Utilisation_Hourly`.
- To find everything that references the table, run this on a server:

  ```sql
  SELECT OBJECT_NAME(object_id) AS ReferencingObject
  FROM sys.sql_modules
  WHERE definition LIKE N'%CPU[_]Utilisation[_]History%';
  ```

  Also search the repository, including `07_jobs/`.

You only need to change `object_manifest.csv` if a `DependsOn` changes. Migrations are not objects, so they are listed separately.

### Step 4: Register the migration and regenerate

Add a row to `10_metadata/migration_manifest.csv` giving the file name and the object it changes:

```csv
MigrationFile,ObjectName
20261026_01_CPU_Utilisation_History_AddServerName.sql,CPU_Utilisation_History
```

`ObjectName` must be an object in `object_manifest.csv`. It decides which package scripts run the migration: any package that deploys `CPU_Utilisation_History` runs it, and `deploy_all.sql` runs every migration.

Then run the generator from the repository root:

```powershell
.\tools\generate_deploy.ps1
```

The generator stops with an error if a `.sql` file in `08_migrations/` isn't listed in the CSV, if a listed file doesn't exist, or if the `ObjectName` isn't in the object manifest. That way a migration can't be silently left out of deployments.

### Step 5: Deploy

Deploy the package, or `deploy_all.sql`, as normal. You no longer run the migration separately:

```
sqlcmd -S <instance> -E -b -v RepoRoot="<repo path>" DatabaseName="<database>" -i 09_deployment\packages\deploy_scc_cpu.sql
```

The generated script runs things in this order:

```
04_tables        CREATE TABLE ... (does nothing if the table exists)
08_migrations    every migration for this package, in file-name order, each followed by a row in dbo.Migration_History
05_views         CREATE OR ALTER
06_programmability
```

**Why migrations run between tables and views.** When SQL Server creates or alters a view or procedure against a table that exists, it checks the columns straight away. If a view that selects `ServerName` were deployed before the column existed, the deployment would fail with `Invalid column name 'ServerName'`. Running migrations after the tables exist and before the views means:

- **Existing server:** the table file does nothing, the migration adds the column, and then the view deploys.
- **New server:** the table file creates the table with the column, the migration prints `Skipped`, and then the view deploys.

**The deployment records each migration it runs.** After each migration completes, the deploy script adds a row to `dbo.Migration_History` with the migration name, deploy script, server, login and UTC time. If a migration fails, `:on error exit` stops the deployment before the row is written. The table gets a new row on every deployment, including runs where the migration found nothing to do. To see when each migration first ran on a server:

```sql
SELECT MigrationName, MIN(RunAt) AS FirstRunUtc, MAX(RunAt) AS LastRunUtc, COUNT(*) AS Runs
FROM dbo.Migration_History
GROUP BY MigrationName
ORDER BY MigrationName;
```

You can still run a migration on its own, for example to test it, with `sqlcmd -S <instance> -E -b -d <database> -i 08_migrations\<file>.sql`. A run like that is not logged.

### Step 6: Test, then raise a pull request

In your own test database on a non-production instance, with the **old** version of the table (deploy `main` into it first, then switch to your branch):

1. Run the package script. The migration should print `Added ...`, and the deployment should finish with no errors.
2. Run the package script again. The migration should print `Skipped ...`, which proves it can be re-run.
3. Check the column: `SELECT TOP (5) * FROM dbo.CPU_Utilisation_History ORDER BY RecordID DESC;`
4. Check the log: `SELECT * FROM dbo.Migration_History ORDER BY RunAt DESC;` should show two rows for the migration.

If you can, also build a scratch database from `deploy_all.sql` and confirm the table there matches the upgraded one.

---

## Patterns for other table changes

All of these use the same header and guard approach as the example above.

**Widen a column.** Guard on the current definition:

```sql
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'dbo.Activity_Session_History')
             AND name = N'wait_info' AND max_length <> -1)   -- -1 = (max)
    ALTER TABLE [dbo].[Activity_Session_History] ALTER COLUMN [wait_info] [nvarchar](max) NULL;
```

`ALTER COLUMN` must restate the column's nullability. If you leave out `NULL` or `NOT NULL`, the column becomes nullable.

**Rename a column:**

```sql
IF COL_LENGTH(N'dbo.HealthCheck_Run', N'OldName') IS NOT NULL
   AND COL_LENGTH(N'dbo.HealthCheck_Run', N'NewName') IS NULL
    EXEC sys.sp_rename N'dbo.HealthCheck_Run.OldName', N'NewName', N'COLUMN';
```

Update every view and procedure that uses the old name in the same pull request, and check `07_jobs/` and any external reports.

**Add an index:**

```sql
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE object_id = OBJECT_ID(N'dbo.WaitStats_Capture_History')
                 AND name = N'IX_WaitStats_Capture_History_wait_type')
    CREATE NONCLUSTERED INDEX [IX_WaitStats_Capture_History_wait_type]
        ON [dbo].[WaitStats_Capture_History] ([wait_type], [capture_time]);
```

Add the same `CREATE INDEX` inside the guard in the table file.

**Drop a column.** In the same pull request, remove every reference to the column from views and procedures. The deploy order handles the rest: the migration drops the column, and then the views and procedures are redeployed without it. The exception is a view created `WITH SCHEMABINDING`, which blocks the drop, so it needs its own migration that alters the view first. Drop any default constraint on the column before the column itself:

```sql
IF OBJECT_ID(N'dbo.DF_X_Col', N'D') IS NOT NULL ALTER TABLE [dbo].[X] DROP CONSTRAINT [DF_X_Col];
IF COL_LENGTH(N'dbo.X', N'Col') IS NOT NULL      ALTER TABLE [dbo].[X] DROP COLUMN [Col];
```

**Drop a whole object.** Write a migration with `DROP VIEW IF EXISTS` or `DROP TABLE IF EXISTS`, delete the object's file, remove its manifest row, and run the generator.

**Rename a table: take care.** Migrations run *after* the table files. If you rename `Old_History` to `New_History` and also rename the table file, a deployment on an existing server first creates an **empty** `New_History`, because that name doesn't exist yet. The migration then can't rename `Old_History` onto it. For a table rename, run the rename migration on its own on each existing server **before** deploying (as shown at the end of Step 5). Write its guard so it only acts while `Old_History` exists and `New_History` does not. When the deployment later runs it, the guard skips it.

**Multi-step changes.** If a migration does several things that must all succeed together, such as adding a column, backfilling it and then making it `NOT NULL`, wrap them in `BEGIN TRAN` / `COMMIT` with `SET XACT_ABORT ON`.

## Rules for migrations

1. **Forward-only.** Once a migration has run on any shared server, never edit or delete it. If it was wrong, write a new migration that fixes it. To undo a change, you also write a new migration.
2. **Re-runnable.** Every statement is guarded, so running a migration twice changes nothing the second time. This is required, not just good practice: every deployment runs every migration again.
3. **Review big changes before merging.** Once a migration is merged, it runs on each server at that server's next deployment. A column drop, a type change on a large table, or a long backfill will happen during a routine deploy, so check it before it goes into `main`.
4. **One logical change per file.** This keeps the history readable and lets you run changes one at a time.
5. **Always update the current-state file in the same pull request.** A migration without the matching object-file change means new servers are built with the wrong table.
6. **No `USE` statements, and every object is schema-qualified with `[dbo]`.**
7. **Never use migrations on vendor objects.** Third-party code in `02_third_party/` is only ever replaced with a new vendor release.

## Checklist

- [ ] Migration named `YYYYMMDD_NN_<ObjectName>_<Change>.sql`, with the full header filled in
- [ ] Guards cover both "table missing" and "already applied"
- [ ] Constraints and indexes have explicit names
- [ ] Table file updated to the same end state
- [ ] Dependent views and procedures updated, and `DependsOn` changed if needed
- [ ] Row added to `10_metadata/migration_manifest.csv`, and `.\tools\generate_deploy.ps1` run
- [ ] Package script run twice on a server with the old table: `Added`, then `Skipped`, with two rows in `dbo.Migration_History`
