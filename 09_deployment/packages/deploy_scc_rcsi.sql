-- ============================================================================
-- deploy_scc_rcsi.sql - SCC_RCSI - Snapshot Isolation Monitoring
-- ============================================================================
-- RCSI / version store / tempdb snapshot capture and views.
--
-- Own objects: 10   Vendor objects: 0   Pulled from other packages: 0
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

:r $(RepoRoot)\04_tables\rcsi\RCSI_ActiveTransactions_Extended_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_ActiveTransactions_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_TempdbUsage_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_VersionStoreUsage_History.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_ActiveTransactions.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_ActiveTransactions_Extended.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_TempdbUsage.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_VersionStoreUsage.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_VersionStore_Sessions.sql
:r $(RepoRoot)\06_programmability\procedures\rcsi\usp_Monitor_CaptureRCSISnapshot.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
