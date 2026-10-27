-- ============================================================================
-- deploy_scc_instance.sql - SCC_Performance - Instance Diagnostics
-- ============================================================================
-- Instance-level diagnostic views (transactions, connections, top queries, waits).
--
-- Own objects: 13   Vendor objects: 0   Pulled from other packages: 0
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

:r $(RepoRoot)\05_views\instance\vw_Instance_ActiveTransactions.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_ConnectionCount.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_LogFile_Usage.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_TopWaits.sql
:r $(RepoRoot)\05_views\query\vw_Query_ActiveTransactionsAlert.sql
:r $(RepoRoot)\05_views\query\vw_Query_ActiveTransactionsAlert_LongText.sql
:r $(RepoRoot)\05_views\query\vw_Query_MissingIndexes.sql
:r $(RepoRoot)\05_views\query\vw_Query_Transactions.sql
:r $(RepoRoot)\05_views\query\vw_Query_TopAvgElapsedTime.sql
:r $(RepoRoot)\05_views\query\vw_Query_TopTotalLogicalReads.sql
:r $(RepoRoot)\05_views\query\vw_Query_TopTotalWorkerTime.sql
:r $(RepoRoot)\05_views\query\vw_Query_UDFStatsByDatabase.sql
:r $(RepoRoot)\06_programmability\procedures\query\usp_Alert_LongRunningTransactions.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
