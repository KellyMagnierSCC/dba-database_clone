-- ============================================================================
-- TEMPLATE: MIGRATION (change to an existing table)
-- Copy this file to:  08_migrations/YYYYMMDD_NN_<ObjectName>_<Change>.sql
-- Fill in the header, write the guarded change, and ALSO update the table's
-- current-state file in 04_tables so new servers get the same end result.
-- See docs/how-to/03_changing-existing-objects-and-migrations.md.
-- Register it in 10_metadata/migration_manifest.csv (MigrationFile,ObjectName) and run
-- tools\generate_deploy.ps1. The deploy scripts then run it on every deployment, after
-- 04_tables and before 05_views, so the "already applied" guard below is essential.
-- ============================================================================
-- Migration : YYYYMMDD_NN_<ObjectName>_<Change>
-- Author    : <your name>
-- Date      : YYYY-MM-DD
-- Ticket    : <change / ticket ref>
-- Package   : <PackageName>
-- Purpose   : <what changes and why>
-- Also changed: 04_tables/<domain>/<TableName>.sql (current state)
-- Re-runnable: yes (required) - skips if the table is missing or the change is already applied
-- ============================================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'[dbo].[Domain_Thing_History]', N'U') IS NULL
    PRINT N'Skipped: dbo.Domain_Thing_History does not exist (it will be created in its current state).';
ELSE IF COL_LENGTH(N'dbo.Domain_Thing_History', N'NewColumn') IS NOT NULL   -- "already applied" check
    PRINT N'Skipped: dbo.Domain_Thing_History.NewColumn already exists.';
ELSE
BEGIN
    ALTER TABLE [dbo].[Domain_Thing_History]
        ADD [NewColumn] [int] NULL;
        -- NOT NULL needs a named default, e.g.
        -- ADD [NewColumn] [int] NOT NULL CONSTRAINT [DF_Domain_Thing_History_NewColumn] DEFAULT (0);

    PRINT N'Applied: added dbo.Domain_Thing_History.NewColumn.';
END
GO
