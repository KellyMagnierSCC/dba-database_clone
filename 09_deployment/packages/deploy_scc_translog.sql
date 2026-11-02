-- ============================================================================
-- deploy_scc_translog.sql - SCC_Performance - Transaction Log Monitoring
-- ============================================================================
-- Transaction log usage and log autogrowth capture, with views over the history.
--
-- Own objects: 6   Vendor objects: 0   Pulled from other packages: 0
--
-- Settings are supplied when you deploy, not stored in the repo (see 09_deployment\config.sql).
-- sqlcmd:
--   sqlcmd -S <instance> -E -b -v RepoRoot="D:\DevOps\dba-database" DatabaseName="DBA" -i <this file>
-- SSMS (Query > SQLCMD Mode): run your own 09_deployment\local_deploy.sql
--   (copy local_deploy.example.sql; it is not committed).
-- RepoRoot must be a full path without spaces: the :r paths are unquoted because SSMS
-- does not expand variables inside a quoted path.
-- ============================================================================
:r $(RepoRoot)\09_deployment\config.sql
:on error exit
GO
USE [$(DatabaseName)]
GO

:r $(RepoRoot)\04_tables\instance\LogUsage_History.sql
:r $(RepoRoot)\04_tables\instance\LogGrowth_History.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_LogUsage_Latest.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_LogGrowth_Last7Days.sql
:r $(RepoRoot)\06_programmability\procedures\instance\usp_Monitor_CaptureLogUsage.sql
:r $(RepoRoot)\06_programmability\procedures\instance\usp_Monitor_CaptureLogGrowth.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
