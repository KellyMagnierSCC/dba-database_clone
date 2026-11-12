-- ============================================================================
-- TEMPLATE: REFERENCE DATA (standard rows for a table)
-- Copy this file to:  11_reference_data/<domain>/<TableName>.sql  (named after the table)
-- Replace Domain_Thing_Lookup, the columns and the rows, then delete this header block.
-- Register it in 10_metadata/reference_data_manifest.csv (DataFile,ObjectName), e.g.
--   <domain>/<TableName>.sql,<TableName>
-- and run tools\generate_deploy.ps1. The deploy scripts run it on every deployment, after
-- the procedures, so it must be re-runnable: a single MERGE is.
-- Only the rows are kept here. The table itself stays in 04_tables (and 08_migrations).
--
-- Choose ONE of the two NOT MATCHED BY SOURCE clauses below:
--   A. The repository owns the whole table (same rows on every server):
--        WHEN NOT MATCHED BY SOURCE THEN DELETE
--   B. The table also holds rows added on each server: give it an
--        IsStandard bit NOT NULL CONSTRAINT [DF_<Table>_IsStandard] DEFAULT ((0))
--      column, set IsStandard = 1 in the INSERT and UPDATE, and use
--        WHEN NOT MATCHED BY SOURCE AND t.IsStandard = 1 THEN DELETE
--      See 11_reference_data/blitz_scc/Scc_HealthCheck_AcceptedRisk.sql for a worked example.
-- ============================================================================
-- Reference data: dbo.Domain_Thing_Lookup
-- <What the rows are for, and which views or procedures read them>
-- ============================================================================
SET NOCOUNT ON;

DECLARE @Changes TABLE (Action nvarchar(10) NOT NULL);

MERGE [dbo].[Domain_Thing_Lookup] AS t
USING (VALUES
    -- KeyColumn, ValueColumn
    (1, N'First value'),
    (2, N'Second value')
) AS s (KeyColumn, ValueColumn)
    ON t.KeyColumn = s.KeyColumn
WHEN MATCHED AND EXISTS (SELECT s.ValueColumn EXCEPT SELECT t.ValueColumn)   -- only real changes; NULL-safe
    THEN UPDATE SET ValueColumn = s.ValueColumn
WHEN NOT MATCHED BY TARGET
    THEN INSERT (KeyColumn, ValueColumn) VALUES (s.KeyColumn, s.ValueColumn)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE
OUTPUT $action INTO @Changes (Action);

PRINT CONCAT(N'Domain_Thing_Lookup: ',
             (SELECT COUNT(*) FROM @Changes WHERE Action = N'INSERT'), N' inserted, ',
             (SELECT COUNT(*) FROM @Changes WHERE Action = N'UPDATE'), N' updated, ',
             (SELECT COUNT(*) FROM @Changes WHERE Action = N'DELETE'), N' deleted.');
GO
