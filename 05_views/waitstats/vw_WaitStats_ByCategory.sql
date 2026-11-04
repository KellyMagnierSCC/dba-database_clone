SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Is it CPU, IO, locking or memory? One row per hour per wait category, with the category's
-- share of the hour's (non-benign) wait time.
--
-- The categories follow the ones Query Store uses (sys.query_store_wait_stats). Wait types that
-- don't match a category are 'Other'. The CASE is checked top to bottom, so the order matters:
-- PAGEIOLATCH_ and PAGELATCH_ come before LATCH_. In LIKE patterns, [_] is a literal underscore.
--
-- wait_ms_per_sec divides by the seconds the hour's captures covered, so hours with missed
-- captures compare fairly. had_reset = 1 when the counters were reset in that hour.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_ByCategory]
AS
WITH Coverage AS
(
    SELECT
        DATEADD(HOUR, DATEDIFF(HOUR, 0, capture_time), 0) AS capture_hour,
        SUM(interval_seconds)                             AS captured_seconds,
        MAX(is_reset)                                     AS had_reset
    FROM dbo.vw_WaitStats_Captures
    WHERE prev_capture_time IS NOT NULL
    GROUP BY DATEADD(HOUR, DATEDIFF(HOUR, 0, capture_time), 0)
),
Categorised AS
(
    SELECT
        DATEADD(HOUR, DATEDIFF(HOUR, 0, d.capture_time), 0) AS capture_hour,
        d.wait_type,
        d.delta_waiting_tasks,
        d.delta_wait_time_ms,
        d.delta_signal_wait_time_ms,
        CASE
            WHEN d.wait_type = N'SOS_SCHEDULER_YIELD'              THEN N'CPU'
            WHEN d.wait_type = N'THREADPOOL'                       THEN N'Worker Thread'
            WHEN d.wait_type LIKE N'LCK[_]M[_]%'                   THEN N'Lock'
            WHEN d.wait_type LIKE N'PAGEIOLATCH[_]%'               THEN N'Buffer IO'
            WHEN d.wait_type LIKE N'PAGELATCH[_]%'                 THEN N'Buffer Latch'
            WHEN d.wait_type LIKE N'LATCH[_]%'                     THEN N'Latch'
            WHEN d.wait_type = N'RESOURCE_SEMAPHORE_QUERY_COMPILE' THEN N'Compilation'
            WHEN d.wait_type IN (N'RESOURCE_SEMAPHORE', N'CMEMTHREAD', N'CMEMPARTITIONED', N'EE_PMOLOCK',
                                 N'MEMORY_ALLOCATION_EXT', N'RESERVED_MEMORY_ALLOCATION_EXT', N'MEMORY_GRANT_UPDATE')
                                                                   THEN N'Memory'
            WHEN d.wait_type IN (N'WRITELOG', N'LOGBUFFER', N'LOGMGR', N'LOGMGR_RESERVE_APPEND', N'LOGMGR_FLUSH',
                                 N'LOGMGR_PMM_LOG', N'CHKPT')      THEN N'Tran Log IO'
            WHEN d.wait_type IN (N'LOG_RATE_GOVERNOR', N'POOL_LOG_RATE_GOVERNOR', N'HADR_THROTTLE_LOG_RATE_GOVERNOR',
                                 N'INSTANCE_LOG_RATE_GOVERNOR')    THEN N'Log Rate Governor'
            WHEN d.wait_type IN (N'ASYNC_NETWORK_IO', N'NET_WAITFOR_PACKET', N'PROXY_NETWORK_IO',
                                 N'EXTERNAL_SCRIPT_NETWORK_IOF')   THEN N'Network IO'
            WHEN d.wait_type IN (N'CXPACKET', N'CXCONSUMER', N'CXSYNC_PORT', N'CXSYNC_CONSUMER', N'EXCHANGE')
              OR d.wait_type LIKE N'HT[BDMR]%'      -- HTBUILD, HTDELETE, HTMEMO, HTREINIT, HTREPARTITION (not HTTP_)
              OR d.wait_type LIKE N'BMP%'
              OR d.wait_type = N'BPSORT'                           THEN N'Parallelism'
            WHEN d.wait_type IN (N'ASYNC_IO_COMPLETION', N'IO_COMPLETION', N'BACKUPIO', N'WRITE_COMPLETION',
                                 N'IO_QUEUE_LIMIT', N'IO_RETRY')   THEN N'Other Disk IO'
            WHEN d.wait_type LIKE N'HADR[_]%'
              OR d.wait_type LIKE N'PWAIT[_]HADR%'
              OR d.wait_type LIKE N'SE[_]REPL[_]%'
              OR d.wait_type LIKE N'REPL[_]%'
              OR d.wait_type IN (N'REPLICA_WRITES', N'FCB_REPLICA_WRITE', N'FCB_REPLICA_READ')
                                                                   THEN N'Replication'
            WHEN d.wait_type LIKE N'XACT%'
              OR d.wait_type LIKE N'DTC%'
              OR d.wait_type LIKE N'TRAN[_]MARKLATCH[_]%'
              OR d.wait_type LIKE N'MSQL[_]XACT[_]%'
              OR d.wait_type = N'TRANSACTION_MUTEX'                THEN N'Transaction'
            WHEN d.wait_type LIKE N'PREEMPTIVE[_]%'                THEN N'Preemptive'
            WHEN d.wait_type LIKE N'CLR%'
              OR d.wait_type LIKE N'SQLCLR%'                       THEN N'SQL CLR'
            WHEN d.wait_type LIKE N'DBMIRROR%'                     THEN N'Mirroring'
            WHEN d.wait_type LIKE N'BROKER[_]%'                    THEN N'Service Broker'
            WHEN d.wait_type LIKE N'FT[_]%'
              OR d.wait_type LIKE N'FULLTEXT%'
              OR d.wait_type LIKE N'MSSEARCH%'                     THEN N'Full Text Search'
            WHEN d.wait_type = N'TRACEWRITE'
              OR d.wait_type LIKE N'SQLTRACE[_]%'
              OR d.wait_type IN (N'QUERY_TRACEOUT', N'TRACE_EVTNOTIF')
                                                                   THEN N'Tracing'
            WHEN d.wait_type IN (N'WAITFOR', N'WAIT_FOR_RESULTS')  THEN N'User Wait'
            WHEN d.wait_type LIKE N'SLEEP[_]%'                     THEN N'Idle'
            ELSE N'Other'
        END AS wait_category
    FROM dbo.vw_WaitStats_Delta AS d
),
HourTotals AS
(
    SELECT
        capture_hour,
        wait_category,
        COUNT(DISTINCT wait_type)      AS wait_types,
        SUM(delta_waiting_tasks)       AS waiting_tasks,
        SUM(delta_wait_time_ms)        AS wait_time_ms,
        SUM(delta_signal_wait_time_ms) AS signal_wait_time_ms
    FROM Categorised
    GROUP BY capture_hour, wait_category
)
SELECT
    t.capture_hour,
    t.wait_category,
    t.wait_types,
    t.waiting_tasks,
    t.wait_time_ms,
    t.signal_wait_time_ms,
    t.wait_time_ms - t.signal_wait_time_ms                                                    AS resource_wait_time_ms,
    CAST(100.0 * t.wait_time_ms / NULLIF(SUM(t.wait_time_ms) OVER (PARTITION BY t.capture_hour), 0)
         AS decimal(5,2))                                                                     AS pct_of_hour,
    CAST(100.0 * t.signal_wait_time_ms / NULLIF(t.wait_time_ms, 0) AS decimal(5,2))          AS signal_pct,
    CAST(t.wait_time_ms * 1.0 / NULLIF(c.captured_seconds, 0) AS decimal(19,3))              AS wait_ms_per_sec,
    c.captured_seconds,
    c.had_reset
FROM HourTotals AS t
JOIN Coverage AS c
    ON c.capture_hour = t.capture_hour;
GO
