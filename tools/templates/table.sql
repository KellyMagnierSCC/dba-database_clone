-- ============================================================================
-- TEMPLATE: TABLE
-- Copy this file to:  04_tables/<domain>/<TableName>.sql
-- Then replace every occurrence of  Domain_Thing_History  with your table name
-- (file name = table name), define the columns, and delete this header block.
--
-- Rules
--   * Keep the IF OBJECT_ID(...) IS NULL guard. Re-running the file must never
--     change an existing table - changes to an existing table go in 08_migrations.
--   * Name every constraint and index: PK_<Table>, DF_<Table>_<Column>,
--     FK_<Table>_<RefTable>, IX_<Table>_<Columns>. No auto-generated names.
--   * Keep constraints and indexes inside the BEGIN ... END guard.
--   * No USE statement. Always schema-qualify with [dbo].
--
-- Manifest row to add to 10_metadata/object_manifest.csv (then run tools\generate_deploy.ps1):
--   Table,dbo,Domain_Thing_History,04_tables/<domain>/Domain_Thing_History.sql,<domain>,<PackageName>,FALSE,,<DependsOn>,<DeployOrder>
-- ============================================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Domain_Thing_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Domain_Thing_History](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	-- add your columns here, e.g.
	-- [DatabaseName] [sysname] NOT NULL,
	-- [SomeValue] [bigint] NULL,
	[CaptureDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Domain_Thing_History] PRIMARY KEY CLUSTERED
(
	[RecordID] ASC
)
) ON [PRIMARY];
ALTER TABLE [dbo].[Domain_Thing_History] ADD CONSTRAINT [DF_Domain_Thing_History_CaptureDate] DEFAULT (sysutcdatetime()) FOR [CaptureDate];
-- optional: indexes
-- CREATE NONCLUSTERED INDEX [IX_Domain_Thing_History_CaptureDate] ON [dbo].[Domain_Thing_History] ([CaptureDate]);
END
GO
