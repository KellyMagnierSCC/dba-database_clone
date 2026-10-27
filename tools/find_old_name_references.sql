-- ============================================================================
-- find_old_name_references.sql  (GENERATED from 10_metadata/rename_map.csv)
-- DIAGNOSTIC - not part of any deploy script.
--
-- Run BEFORE the rename migration. Lists SQL Agent job steps (msdb) and module
-- definitions in the current database that still mention a pre-rename name.
-- Agent steps, application code and linked-server queries are NOT updated by the repo.
-- ============================================================================
SET NOCOUNT ON;
DECLARE @Old TABLE (OldName sysname NOT NULL);
INSERT @Old (OldName) VALUES
    (N'SP_WHOISACTIVE_ActivityData'),
    (N'SP_WHOISACTIVE_BlockingData'),
    (N'SP_WHOISACTIVE_BlockingTree'),
    (N'FileStat_DB_History'),
    (N'BlitzRun'),
    (N'BlitzFinding'),
    (N'BlitzFinding_Stage'),
    (N'SccBaselineRule'),
    (N'SccAcceptedRisk'),
    (N'vw_ActivityMonitor_BlockedSesionCount_last5Runs'),
    (N'vw_ActivityMonitor_Sessions_lastcollection'),
    (N'vw_ActivityMonitor_SessionsGreater60Mins_lastcollection'),
    (N'vw_BlockingMonitor_Blockingtree_lastcollection'),
    (N'vw_BlockingMonitor_Blockingtree'),
    (N'vw_FileStat_DB_Current'),
    (N'vw_FileStat_DB_Delta'),
    (N'vw_FileStat_DB_PctChange'),
    (N'vw_FileStat_DB_RollingAvg'),
    (N'vw_FileStat_DB_Spikes'),
    (N'vw_IO_UsageByDB'),
    (N'vw_CPU_UsageByDB'),
    (N'vw_CPU_UsageTopSessions'),
    (N'vw_CPU_UtilLast256Mins'),
    (N'vw_MEM_BufferPoolUsage'),
    (N'vw_MEM_ClerkUsage'),
    (N'vw_MEM_GrantsPending'),
    (N'vw_MEM_SystemGeneral'),
    (N'vw_QUERY_MissingIndexes'),
    (N'vw_QUERY_TopAvgElapsedTime'),
    (N'vw_QUERY_TopTotalLogicalReads'),
    (N'vw_QUERY_TopTotalWorkerTime'),
    (N'vw_QUERY_TRANSACTIONS'),
    (N'vw_QUERY_UDFStatsByDB'),
    (N'vw_QRY_ActiveTransactionsNotification'),
    (N'vw_QRY_ActiveTransactionsNotification_SqlLongText'),
    (N'vw_INSTANCE_ActiveTransactions'),
    (N'vw_INSTANCE_LogFile_Usage'),
    (N'vw_INSTANCE_CountSQLConnections'),
    (N'vw_INSTANCE_TopWaits'),
    (N'vw_admin_BackupRestoreCompletionEstimate'),
    (N'vw_admin_CommvaultLastBackups'),
    (N'WaitStats_Top5WaitsPerBucket_5mins'),
    (N'Capture_FileStats_History'),
    (N'Capture_WaitStats_History'),
    (N'Capture_CPU_Utilisation_History'),
    (N'Capture_RCSI_Snapshot'),
    (N'usp_CheckHighCPUAlert'),
    (N'usp_CheckActiveTransactionAlert');

SELECT 'AgentJobStep' AS FoundIn, j.name AS JobName, s.step_id, s.step_name, o.OldName
FROM msdb.dbo.sysjobsteps AS s
JOIN msdb.dbo.sysjobs AS j ON j.job_id = s.job_id
JOIN @Old AS o ON s.command LIKE N'%' + REPLACE(o.OldName, N'_', N'~_') + N'%' ESCAPE N'~'
ORDER BY j.name, s.step_id;

SELECT 'Module' AS FoundIn, OBJECT_SCHEMA_NAME(m.object_id) + N'.' + OBJECT_NAME(m.object_id) AS ObjectName, o.OldName
FROM sys.sql_modules AS m
JOIN @Old AS o ON m.definition LIKE N'%' + REPLACE(o.OldName, N'_', N'~_') + N'%' ESCAPE N'~'
ORDER BY 2, 3;
GO
