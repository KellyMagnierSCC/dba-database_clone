-- ============================================================================
-- TEMPLATE: STORED PROCEDURE
-- Copy this file to:  06_programmability/procedures/<domain>/<ProcName>.sql
-- Then replace  usp_Domain_VerbNoun  with your procedure name (usp_<Domain>_<VerbNoun>;
-- capture procs use usp_Monitor_Capture<Thing>; file name = proc name),
-- put your logic in, and delete this header block.
--
-- Rules
--   * Keep CREATE OR ALTER - every deployment replaces the procedure with this file.
--   * Schema-qualify every object (dbo.TableName). List columns in every INSERT.
--   * No USE statement. Agent jobs should only EXEC this proc - the logic lives here.
--   * If the proc reads another domain's objects, keep a Cross-domain line below.
--
-- Manifest row to add to 10_metadata/object_manifest.csv (then run tools\generate_deploy.ps1):
--   Procedure,dbo,usp_Domain_VerbNoun,06_programmability/procedures/<domain>/usp_Domain_VerbNoun.sql,<domain>,<PackageName>,FALSE,,<DependsOn>,<DeployOrder>
-- ============================================================================
-- Cross-domain: reads dbo.<OtherTable> (<other domain>)   <- delete if not needed
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_Domain_VerbNoun]
    @RetentionDays int = 30          -- example parameter; remove or replace
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- your logic here, e.g.
        -- INSERT INTO dbo.Domain_Thing_History (Column1, Column2)
        -- SELECT ...;

        -- DELETE FROM dbo.Domain_Thing_History
        -- WHERE CaptureDate < DATEADD(DAY, -@RetentionDays, SYSUTCDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
