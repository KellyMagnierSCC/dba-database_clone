-- ============================================================================
-- deploy_scc_whoisactive.sql - SCC_WhoisActive - Activity and Blocking Monitoring
-- ============================================================================
-- Activity and blocking capture tables and views built around sp_WhoIsActive.
--
-- Own objects: 9   Vendor objects: 1   Pulled from other packages: 1
-- Vendor objects: sp_WhoIsActive
-- Pulled from other packages: Migration_History
-- Migrations: 2 (run after the tables, before the views and procedures)
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

-- 02_third_party (1, from ThirdPartyRequires in packages.csv)
:r $(RepoRoot)\02_third_party\adam_machanic\sp_WhoIsActive.sql

:r $(RepoRoot)\04_tables\infrastructure\Migration_History.sql
:r $(RepoRoot)\04_tables\activity\Activity_Session_History.sql
:r $(RepoRoot)\04_tables\blocking\Blocking_Session_History.sql
:r $(RepoRoot)\04_tables\blocking\Blocking_Tree_History.sql

-- 08_migrations (2)
:r $(RepoRoot)\08_migrations\20261110_01_Activity_Session_History_DropOldCaptureProc.sql
GO
INSERT [dbo].[Migration_History] (MigrationName, DeployScript) VALUES (N'20261110_01_Activity_Session_History_DropOldCaptureProc', N'deploy_scc_whoisactive');
GO
:r $(RepoRoot)\08_migrations\20261110_02_Blocking_Session_History_DropOldCaptureProc.sql
GO
INSERT [dbo].[Migration_History] (MigrationName, DeployScript) VALUES (N'20261110_02_Blocking_Session_History_DropOldCaptureProc', N'deploy_scc_whoisactive');
GO

:r $(RepoRoot)\05_views\blocking\vw_BlockingMonitor_BlockedSessionCount_Last5Runs.sql
:r $(RepoRoot)\05_views\activity\vw_ActivityMonitor_SessionsOver60Min_LastCollection.sql
:r $(RepoRoot)\05_views\activity\vw_ActivityMonitor_Sessions_LastCollection.sql
:r $(RepoRoot)\05_views\blocking\vw_BlockingMonitor_BlockingTree_LastCollection.sql
:r $(RepoRoot)\06_programmability\procedures\activity\usp_Monitor_CaptureActivity.sql
:r $(RepoRoot)\06_programmability\procedures\blocking\usp_Monitor_CaptureBlocking.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
