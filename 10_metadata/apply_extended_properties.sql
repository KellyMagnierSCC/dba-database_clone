-- ============================================================================
-- apply_extended_properties.sql  (GENERATED from 10_metadata/object_manifest.csv)
--
-- Stamps RepositoryGroup, PackageName and IsThirdParty on every table, view and
-- procedure. Safe to re-run: adds missing properties, updates changed ones, leaves
-- identical ones alone, and skips objects that are not in this database (so it can
-- be run after a single-package deployment).
--
-- The legacy single 'Package' property is NOT touched by this script.
-- ============================================================================
SET NOCOUNT ON;

DECLARE @Meta TABLE
(
    SchemaName      sysname       NOT NULL,
    ObjectName      sysname       NOT NULL,
    Level1Type      nvarchar(60)  NOT NULL,
    RepositoryGroup nvarchar(128) NOT NULL,
    PackageName     nvarchar(256) NOT NULL,
    IsThirdParty    nvarchar(5)   NOT NULL
);

INSERT @Meta (SchemaName, ObjectName, Level1Type, RepositoryGroup, PackageName, IsThirdParty)
VALUES
    (N'dbo', N'Migration_History', N'TABLE', N'infrastructure', N'', N'False'),
    (N'dbo', N'Blitz_Finding_Stage', N'TABLE', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'Blitz_Run', N'TABLE', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'Blitz_Finding', N'TABLE', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'CPU_Utilisation_History', N'TABLE', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'FileStat_Database_History', N'TABLE', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'FileStat_Drive_History', N'TABLE', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'RCSI_ActiveTransactions_Extended_History', N'TABLE', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'RCSI_ActiveTransactions_History', N'TABLE', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'RCSI_TempdbUsage_History', N'TABLE', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'RCSI_VersionStoreUsage_History', N'TABLE', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'WhoIsActive_ActivityData', N'TABLE', N'activity', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'WhoIsActive_BlockingData', N'TABLE', N'blocking', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'WhoIsActive_BlockingTree', N'TABLE', N'blocking', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'Scc_AcceptedRisk', N'TABLE', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'Scc_BaselineRule', N'TABLE', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'WaitStats_Capture_History', N'TABLE', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'WhoIsActive_ResultSet', N'TABLE', N'activity', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'WorkloadMetricsTestQueries', N'TABLE', N'workload_metrics', N'SCC_Performance - Workload Metrics', N'False'),
    (N'dbo', N'WorkloadMetricsTestRuns', N'TABLE', N'workload_metrics', N'SCC_Performance - Workload Metrics', N'False'),
    (N'dbo', N'WorkloadMetricsTestDurations', N'TABLE', N'workload_metrics', N'SCC_Performance - Workload Metrics', N'False'),
    (N'dbo', N'WorkloadMetricsTestIOStats', N'TABLE', N'workload_metrics', N'SCC_Performance - Workload Metrics', N'False'),
    (N'dbo', N'WorkloadMetricsTestWaitStats', N'TABLE', N'workload_metrics', N'SCC_Performance - Workload Metrics', N'False'),
    (N'dbo', N'LogUsage_History', N'TABLE', N'instance', N'SCC_Performance - Transaction Log Monitoring', N'False'),
    (N'dbo', N'LogGrowth_History', N'TABLE', N'instance', N'SCC_Performance - Transaction Log Monitoring', N'False'),
    (N'dbo', N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs', N'VIEW', N'activity', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'vw_ActivityMonitor_SessionsOver60Min_LastCollection', N'VIEW', N'activity', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'vw_ActivityMonitor_Sessions_LastCollection', N'VIEW', N'activity', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'vw_Blitz_LatestRun', N'VIEW', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'vw_Blitz_LatestFindings', N'VIEW', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'vw_BlockingMonitor_BlockingTree_LastCollection', N'VIEW', N'blocking', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'vw_CPU_HighUsage_Now', N'VIEW', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'vw_CPU_History_15minute_Interval', N'VIEW', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'vw_CPU_UsageByDatabase', N'VIEW', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'vw_CPU_TopSessions', N'VIEW', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'vw_CPU_UtilLast256Min', N'VIEW', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'vw_CPU_Utilisation_Hourly', N'VIEW', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'vw_FileStat_Database_Current', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Database_Delta', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Database_PctChange', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Database_RollingAvg', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Database_Spikes', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Drive_Current', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Drive_Delta', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Drive_PctChange', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Drive_RollingAvg', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_FileStat_Drive_Spikes', N'VIEW', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_Instance_ActiveTransactions', N'VIEW', N'instance', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Instance_ConnectionCount', N'VIEW', N'instance', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Instance_LogFile_Usage', N'VIEW', N'instance', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Instance_TopWaits', N'VIEW', N'instance', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_IO_UsageByDatabase', N'VIEW', N'io', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'vw_Memory_BufferPoolUsage', N'VIEW', N'memory', N'SCC_Performance - Memory Monitoring', N'False'),
    (N'dbo', N'vw_Memory_ClerkUsage', N'VIEW', N'memory', N'SCC_Performance - Memory Monitoring', N'False'),
    (N'dbo', N'vw_Memory_GrantsPending', N'VIEW', N'memory', N'SCC_Performance - Memory Monitoring', N'False'),
    (N'dbo', N'vw_Memory_SystemGeneral', N'VIEW', N'memory', N'SCC_Performance - Memory Monitoring', N'False'),
    (N'dbo', N'vw_Query_ActiveTransactionsAlert', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_ActiveTransactionsAlert_LongText', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_MissingIndexes', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_Transactions', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_TopAvgElapsedTime', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_TopTotalLogicalReads', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_TopTotalWorkerTime', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_Query_UDFStatsByDatabase', N'VIEW', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'vw_RCSI_ActiveTransactions', N'VIEW', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'vw_RCSI_ActiveTransactions_Extended', N'VIEW', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'vw_RCSI_TempdbUsage', N'VIEW', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'vw_RCSI_VersionStoreUsage', N'VIEW', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'vw_RCSI_VersionStore_Sessions', N'VIEW', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'vw_Scc_ComplianceFailures_Mandatory', N'VIEW', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'vw_Scc_ComplianceFailures_Sysadmin', N'VIEW', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'vw_WaitStats_BenignWaits', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_Current', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_Captures', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_Delta', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_RollingDelta', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_DailyTrend', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_ByCategory', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_CaptureHealth', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_Top5WaitsPerBucket', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WorkloadMetricsComparison', N'VIEW', N'workload_metrics', N'SCC_Performance - Workload Metrics', N'False'),
    (N'dbo', N'vw_WaitStats_Top5WaitsPerDay', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_WaitStats_Top5WaitsPerBucket_5mins', N'VIEW', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'vw_Admin_BackupRestoreEstimate', N'VIEW', N'admin', N'SCC_Admin - Backup and Administration', N'False'),
    (N'dbo', N'vw_Admin_CommvaultLastBackups', N'VIEW', N'admin', N'SCC_Admin - Backup and Administration', N'False'),
    (N'dbo', N'vw_Instance_LogUsage_Latest', N'VIEW', N'instance', N'SCC_Performance - Transaction Log Monitoring', N'False'),
    (N'dbo', N'vw_Instance_LogGrowth_Last7Days', N'VIEW', N'instance', N'SCC_Performance - Transaction Log Monitoring', N'False'),
    (N'dbo', N'usp_Monitor_CaptureCpuUtilisation', N'PROCEDURE', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'usp_Monitor_CaptureFileStats', N'PROCEDURE', N'filestat', N'SCC_Performance - File and IO Statistics', N'False'),
    (N'dbo', N'usp_Monitor_CaptureRCSISnapshot', N'PROCEDURE', N'rcsi', N'SCC_RCSI - Snapshot Isolation Monitoring', N'False'),
    (N'dbo', N'usp_Monitor_CaptureWaitStats', N'PROCEDURE', N'waitstats', N'SCC_Performance - Wait Statistics Monitoring', N'False'),
    (N'dbo', N'usp_Run_Blitz', N'PROCEDURE', N'blitz_scc', N'SCC_Blitz - Health Check Framework', N'False'),
    (N'dbo', N'usp_WhoIsActive_ActivityData', N'PROCEDURE', N'activity', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'usp_WhoIsActive_BlockingData', N'PROCEDURE', N'blocking', N'SCC_WhoisActive - Activity and Blocking Monitoring', N'False'),
    (N'dbo', N'usp_Alert_HighCpu', N'PROCEDURE', N'cpu', N'SCC_Performance - CPU Monitoring', N'False'),
    (N'dbo', N'usp_Alert_LongRunningTransactions', N'PROCEDURE', N'query', N'SCC_Performance - Instance Diagnostics', N'False'),
    (N'dbo', N'usp_Monitor_CaptureLogUsage', N'PROCEDURE', N'instance', N'SCC_Performance - Transaction Log Monitoring', N'False'),
    (N'dbo', N'usp_Monitor_CaptureLogGrowth', N'PROCEDURE', N'instance', N'SCC_Performance - Transaction Log Monitoring', N'False');

DECLARE @Schema sysname, @Object sysname, @Type nvarchar(60),
        @PropName sysname, @PropValue nvarchar(4000), @Current nvarchar(4000),
        @Added int = 0, @Updated int = 0, @Unchanged int = 0, @Skipped int = 0;

DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT m.SchemaName, m.ObjectName, m.Level1Type, p.PropName, p.PropValue
    FROM @Meta AS m
    CROSS APPLY (VALUES (N'RepositoryGroup', m.RepositoryGroup),
                        (N'PackageName',     m.PackageName),
                        (N'IsThirdParty',    m.IsThirdParty)) AS p (PropName, PropValue)
    ORDER BY m.SchemaName, m.ObjectName, p.PropName;

OPEN c;
FETCH NEXT FROM c INTO @Schema, @Object, @Type, @PropName, @PropValue;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID(QUOTENAME(@Schema) + N'.' + QUOTENAME(@Object)) IS NULL
        SET @Skipped += 1;
    ELSE
    BEGIN
        SET @Current = NULL;
        SELECT @Current = CONVERT(nvarchar(4000), value)
        FROM sys.fn_listextendedproperty(@PropName, N'SCHEMA', @Schema, @Type, @Object, NULL, NULL);

        IF @Current IS NULL
        BEGIN
            EXEC sys.sp_addextendedproperty @name = @PropName, @value = @PropValue,
                 @level0type = N'SCHEMA', @level0name = @Schema,
                 @level1type = @Type,     @level1name = @Object;
            SET @Added += 1;
        END
        ELSE IF @Current <> @PropValue
        BEGIN
            EXEC sys.sp_updateextendedproperty @name = @PropName, @value = @PropValue,
                 @level0type = N'SCHEMA', @level0name = @Schema,
                 @level1type = @Type,     @level1name = @Object;
            SET @Updated += 1;
        END
        ELSE
            SET @Unchanged += 1;
    END;
    FETCH NEXT FROM c INTO @Schema, @Object, @Type, @PropName, @PropValue;
END
CLOSE c;
DEALLOCATE c;

PRINT CONCAT(N'Extended properties: ', @Added, N' added, ', @Updated, N' updated, ',
             @Unchanged, N' unchanged, ', @Skipped, N' skipped (object not present).');
GO
