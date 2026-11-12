-- ============================================================================
-- deploy_all.sql - full deployment: folders 00-06 in order, with 08_migrations run after 04_tables and 11_reference_data last (idempotent, re-runnable).
-- Vendor code can also be deployed on its own with deploy_third_party.sql.
-- ============================================================================
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

-- 00_database (runs in master)
:r $(RepoRoot)\00_database\01_create_database.sql
GO
USE [$(DatabaseName)]
GO

-- 01_security (1 objects)
:r $(RepoRoot)\01_security\01_users_roles.sql

-- 02_third_party (4 objects)
:r $(RepoRoot)\02_third_party\ola_hallengren\MaintenanceSolution.sql
:r $(RepoRoot)\02_third_party\brent_ozar\Install-All-Scripts.sql
:r $(RepoRoot)\02_third_party\adam_machanic\sp_WhoIsActive.sql
:r $(RepoRoot)\02_third_party\erik_darling\DarlingData.sql

-- 03_types (none yet) (0 objects)

-- 04_tables (24 objects)
:r $(RepoRoot)\04_tables\infrastructure\Migration_History.sql
:r $(RepoRoot)\04_tables\blitz_scc\Blitz_Finding_Stage.sql
:r $(RepoRoot)\04_tables\blitz_scc\Blitz_Run.sql
:r $(RepoRoot)\04_tables\blitz_scc\Blitz_Finding.sql
:r $(RepoRoot)\04_tables\cpu\CPU_Utilisation_History.sql
:r $(RepoRoot)\04_tables\filestat\FileStat_Database_History.sql
:r $(RepoRoot)\04_tables\filestat\FileStat_Drive_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_ActiveTransactions_Extended_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_ActiveTransactions_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_TempdbUsage_History.sql
:r $(RepoRoot)\04_tables\rcsi\RCSI_VersionStoreUsage_History.sql
:r $(RepoRoot)\04_tables\activity\Activity_Session_History.sql
:r $(RepoRoot)\04_tables\blocking\Blocking_Session_History.sql
:r $(RepoRoot)\04_tables\blocking\Blocking_Tree_History.sql
:r $(RepoRoot)\04_tables\blitz_scc\Scc_AcceptedRisk.sql
:r $(RepoRoot)\04_tables\blitz_scc\Scc_BaselineRule.sql
:r $(RepoRoot)\04_tables\waitstats\WaitStats_Capture_History.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestQueries.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestRuns.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestDurations.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestIOStats.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestWaitStats.sql
:r $(RepoRoot)\04_tables\instance\LogUsage_History.sql
:r $(RepoRoot)\04_tables\instance\LogGrowth_History.sql

-- 08_migrations (0 migrations, run after the tables exist and before the views and procedures that use them)

-- 05_views (62 objects)
:r $(RepoRoot)\05_views\blocking\vw_BlockingMonitor_BlockedSessionCount_Last5Runs.sql
:r $(RepoRoot)\05_views\activity\vw_ActivityMonitor_SessionsOver60Min_LastCollection.sql
:r $(RepoRoot)\05_views\activity\vw_ActivityMonitor_Sessions_LastCollection.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_Blitz_LatestRun.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_Blitz_LatestFindings.sql
:r $(RepoRoot)\05_views\blocking\vw_BlockingMonitor_BlockingTree_LastCollection.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_HighUsage_Now.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_History_15minute_Interval.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_UsageByDatabase.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_TopSessions.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_UtilLast256Min.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_Utilisation_Hourly.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_Current.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_Delta.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_PctChange.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_RollingAvg.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_Spikes.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_Current.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_Delta.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_PctChange.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_RollingAvg.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_Spikes.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_ActiveTransactions.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_ConnectionCount.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_LogFile_Usage.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_TopWaits.sql
:r $(RepoRoot)\05_views\io\vw_IO_UsageByDatabase.sql
:r $(RepoRoot)\05_views\memory\vw_Memory_BufferPoolUsage.sql
:r $(RepoRoot)\05_views\memory\vw_Memory_ClerkUsage.sql
:r $(RepoRoot)\05_views\memory\vw_Memory_GrantsPending.sql
:r $(RepoRoot)\05_views\memory\vw_Memory_SystemGeneral.sql
:r $(RepoRoot)\05_views\query\vw_Query_ActiveTransactionsAlert.sql
:r $(RepoRoot)\05_views\query\vw_Query_ActiveTransactionsAlert_LongText.sql
:r $(RepoRoot)\05_views\query\vw_Query_MissingIndexes.sql
:r $(RepoRoot)\05_views\query\vw_Query_Transactions.sql
:r $(RepoRoot)\05_views\query\vw_Query_TopAvgElapsedTime.sql
:r $(RepoRoot)\05_views\query\vw_Query_TopTotalLogicalReads.sql
:r $(RepoRoot)\05_views\query\vw_Query_TopTotalWorkerTime.sql
:r $(RepoRoot)\05_views\query\vw_Query_UDFStatsByDatabase.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_ActiveTransactions.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_ActiveTransactions_Extended.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_TempdbUsage.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_VersionStoreUsage.sql
:r $(RepoRoot)\05_views\rcsi\vw_RCSI_VersionStore_Sessions.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_Scc_ComplianceFailures_Mandatory.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_Scc_ComplianceFailures_Sysadmin.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_BenignWaits.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Current.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Captures.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Delta.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_RollingDelta.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_DailyTrend.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_ByCategory.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_CaptureHealth.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Top5WaitsPerBucket.sql
:r $(RepoRoot)\05_views\workload_metrics\vw_WorkloadMetricsComparison.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Top5WaitsPerDay.sql
:r $(RepoRoot)\05_views\waitstats\vw_WaitStats_Top5WaitsPerBucket_5mins.sql
:r $(RepoRoot)\05_views\admin\vw_Admin_BackupRestoreEstimate.sql
:r $(RepoRoot)\05_views\admin\vw_Admin_CommvaultLastBackups.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_LogUsage_Latest.sql
:r $(RepoRoot)\05_views\instance\vw_Instance_LogGrowth_Last7Days.sql

-- 06_programmability (11 objects)
:r $(RepoRoot)\06_programmability\procedures\cpu\usp_Monitor_CaptureCpuUtilisation.sql
:r $(RepoRoot)\06_programmability\procedures\filestat\usp_Monitor_CaptureFileStats.sql
:r $(RepoRoot)\06_programmability\procedures\rcsi\usp_Monitor_CaptureRCSISnapshot.sql
:r $(RepoRoot)\06_programmability\procedures\waitstats\usp_Monitor_CaptureWaitStats.sql
:r $(RepoRoot)\06_programmability\procedures\blitz_scc\usp_Run_Blitz.sql
:r $(RepoRoot)\06_programmability\procedures\activity\usp_Monitor_CaptureActivity.sql
:r $(RepoRoot)\06_programmability\procedures\blocking\usp_Monitor_CaptureBlocking.sql
:r $(RepoRoot)\06_programmability\procedures\cpu\usp_Alert_HighCpu.sql
:r $(RepoRoot)\06_programmability\procedures\query\usp_Alert_LongRunningTransactions.sql
:r $(RepoRoot)\06_programmability\procedures\instance\usp_Monitor_CaptureLogUsage.sql
:r $(RepoRoot)\06_programmability\procedures\instance\usp_Monitor_CaptureLogGrowth.sql

-- 11_reference_data (2 tables, run after the procedures so every table and migration is in place)
:r $(RepoRoot)\11_reference_data\blitz_scc\Scc_AcceptedRisk.sql
:r $(RepoRoot)\11_reference_data\blitz_scc\Scc_BaselineRule.sql

-- 10_metadata
:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
