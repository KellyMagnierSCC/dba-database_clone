-- ============================================================================
-- deploy_scc_waitstats.sql - SCC_Performance - Wait Statistics Monitoring
-- ============================================================================
-- Wait statistics history capture and views.
--
-- Own objects: 14   Vendor objects: 0   Pulled from other packages: 0
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

:r $(RepoRoot)\04_tables\waitstats\WaitStats_History.sql
:r $(RepoRoot)\04_tables\waitstats\WaitStats_Capture_History.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_BenignWaits.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Current.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Captures.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Delta.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_RollingDelta.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_DailyTrend.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_ByCategory.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_CaptureHealth.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Top5WaitsPerBucket.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Top5WaitsPerDay.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Top5WaitsPerBucket_5mins.sql
:r $(RepoRoot)\06_programmability\procedures\waitstats\usp_Monitor_CaptureWaitStats.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
