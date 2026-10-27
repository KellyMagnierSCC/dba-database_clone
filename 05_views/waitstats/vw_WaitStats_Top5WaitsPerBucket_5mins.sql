SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW 
 [dbo].[vw_WaitStats_Top5WaitsPerBucket_5mins]
AS

WITH WaitDeltas AS
(
    SELECT
        CAST(capture_time AS date) AS capture_date,

        -- 5-minute bucket number within the day (0-287)
        DATEDIFF
        (
            MINUTE,
            CAST(CAST(capture_time AS date) AS datetime),
            DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, capture_time) / 5) * 5, 0)
        ) / 5 AS bucket_num,

        -- Display range for the bucket
        CONVERT
        (
            varchar(5),
            DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, capture_time) / 5) * 5, 0),
            108
        )
        + ' - ' +
        CONVERT
        (
            varchar(5),
            DATEADD(MINUTE, ((DATEDIFF(MINUTE, 0, capture_time) / 5) * 5) + 4, 0),
            108
        ) AS time_range,

        wait_type,

        wait_time_ms
        - LAG(wait_time_ms) OVER
        (
            PARTITION BY wait_type
            ORDER BY capture_time
        ) AS delta_wait_ms

    FROM dbo.WaitStats_History
    WHERE wait_type NOT IN
    (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
        N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE', N'CXCONSUMER',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
        N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT',
        N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE',
        N'MEMORY_ALLOCATION_EXT', N'ONDEMAND_TASK_QUEUE',
        N'PARALLEL_REDO_DRAIN_WORKER', N'PARALLEL_REDO_LOG_CACHE', N'PARALLEL_REDO_TRAN_LIST',
        N'PARALLEL_REDO_WORKER_SYNC', N'PARALLEL_REDO_WORKER_WAIT_WORK',
        N'PREEMPTIVE_HADR_LEASE_MECHANISM', N'PREEMPTIVE_SP_SERVER_DIAGNOSTICS',
        N'PREEMPTIVE_OS_LIBRARYOPS', N'PREEMPTIVE_OS_COMOPS', N'PREEMPTIVE_OS_CRYPTOPS',
        N'PREEMPTIVE_OS_PIPEOPS', N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
        N'PREEMPTIVE_OS_GENERICOPS', N'PREEMPTIVE_OS_VERIFYTRUST',
        N'PREEMPTIVE_OS_FILEOPS', N'PREEMPTIVE_OS_DEVICEOPS', N'PREEMPTIVE_OS_QUERYREGISTRY',
        N'PREEMPTIVE_OS_WRITEFILE', N'PREEMPTIVE_OS_WRITEFILEGATHER',
        N'PREEMPTIVE_XE_CALLBACKEXECUTE', N'PREEMPTIVE_XE_DISPATCHER',
        N'PREEMPTIVE_XE_GETTARGETSTATE', N'PREEMPTIVE_XE_SESSIONCOMMIT',
        N'PREEMPTIVE_XE_TARGETINIT', N'PREEMPTIVE_XE_TARGETFINALIZE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
        N'PWAIT_EXTENSIBILITY_CLEANUP_TASK',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
        N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
        N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SOS_WORK_DISPATCHER',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SOS_WORKER_MIGRATION', N'VDI_CLIENT_OTHER',
        N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
        N'STARTUP_DEPENDENCY_MANAGER',
        N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
        N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'WAIT_XTP_RECOVERY',
        N'XE_BUFFERMGR_ALLPROCESSED_EVENT', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_LIVE_TARGET_TVF', N'XE_TIMER_EVENT'
    )
),
BucketTotals AS
(
    SELECT
        capture_date,
        bucket_num,
        time_range,
        wait_type,
        SUM(delta_wait_ms) AS total_wait_ms
    FROM WaitDeltas
    WHERE delta_wait_ms > 0
    GROUP BY
        capture_date,
        bucket_num,
        time_range,
        wait_type
),
RankedWaits AS
(
    SELECT
        capture_date,
        bucket_num,
        time_range,
        wait_type,
        total_wait_ms,

        RANK() OVER
        (
            PARTITION BY capture_date, bucket_num
            ORDER BY total_wait_ms DESC
        ) AS rn,

        SUM(total_wait_ms) OVER
        (
            PARTITION BY capture_date, bucket_num
        ) AS bucket_total_ms

    FROM BucketTotals
)

SELECT
    capture_date,
    bucket_num,
    time_range,
    rn,
    wait_type,
    total_wait_ms,
    CAST
    (
        100.0 * total_wait_ms / NULLIF(bucket_total_ms, 0)
        AS decimal(5,2)
    ) AS pct_of_total
FROM RankedWaits
WHERE rn <= 5;
GO
