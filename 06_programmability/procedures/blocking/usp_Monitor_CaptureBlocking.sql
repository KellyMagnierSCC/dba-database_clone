SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureBlocking]
(
    @CaptureBlockingData BIT = 1,   -- 0 = skip the blocking-detail table
    @BlockingOnly        BIT = 1,   -- 1 = detail table gets only blocked/leader sessions; 0 = every session (as old step 1)
    @PrecheckBlocking    BIT = 1,   -- 0 = always run the full capture
    @MinBlockedMs        INT = 0    -- precheck: only act if a request has waited on a blocker this long
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @rc INT;

    -- Overlap guard: with heavy blocking a plan-collecting capture can be slow,
    -- and stacked runs would add to the problem.
    -- The lock name is still the old procedure name, usp_WhoIsActive_BlockingData, on purpose:
    -- during cutover an Agent job step calling the old procedure and one calling this one
    -- take the same lock, so they cannot overlap. Keep it unchanged.
    EXEC @rc = sys.sp_getapplock
         @Resource    = N'usp_WhoIsActive_BlockingData',
         @LockMode    = N'Exclusive',
         @LockOwner   = N'Session',
         @LockTimeout = 0;

    IF @rc < 0
    BEGIN
        PRINT 'Previous blocking capture still running - skipped.';
        RETURN;
    END;

    BEGIN TRY

        ------------------------------------------------------------
        -- 1. Cheap pre-check: is anything blocked right now?
        ------------------------------------------------------------
        IF @PrecheckBlocking = 1
           AND NOT EXISTS (SELECT 1
                           FROM   sys.dm_exec_requests AS r
                           WHERE  r.blocking_session_id > 0
                             AND  r.wait_time >= @MinBlockedMs
                             AND  r.session_id <> @@SPID)
        BEGIN
            EXEC sys.sp_releaseapplock @Resource = N'usp_WhoIsActive_BlockingData', @LockOwner = N'Session';
            RETURN;
        END;

        ------------------------------------------------------------
        -- 2. Single collection into a temp table
        --    (column order must match @output_column_list below)
        ------------------------------------------------------------
        CREATE TABLE #wia
        (
            [collection_time]       DATETIME       NOT NULL,
            [dd hh:mm:ss.mss]       VARCHAR(8000)  NULL,
            [session_id]            SMALLINT       NOT NULL,
            [sql_text]              XML            NULL,
            [sql_command]           XML            NULL,
            [login_name]            NVARCHAR(128)  NOT NULL,
            [wait_info]             NVARCHAR(4000) NULL,
            [tempdb_allocations]    VARCHAR(50)    NULL,
            [tempdb_current]        VARCHAR(50)    NULL,
            [blocking_session_id]   SMALLINT       NULL,
            [blocked_session_count] VARCHAR(30)    NULL,
            [reads]                 VARCHAR(50)    NULL,
            [writes]                VARCHAR(50)    NULL,
            [physical_reads]        VARCHAR(50)    NULL,
            [used_memory]           VARCHAR(50)    NULL,
            [CPU]                   VARCHAR(50)    NULL,
            [status]                VARCHAR(30)    NOT NULL,
            [open_tran_count]       VARCHAR(30)    NULL,
            [percent_complete]      VARCHAR(30)    NULL,
            [host_name]             NVARCHAR(128)  NULL,
            [database_name]         NVARCHAR(128)  NULL,
            [program_name]          NVARCHAR(128)  NULL,
            [locks]                 XML            NULL,
            [start_time]            DATETIME       NOT NULL,
            [login_time]            DATETIME       NULL,
            [request_id]            INT            NULL,
            [query_plan]            XML            NULL,
            [additional_info]       XML            NULL
        );

        EXEC dba.dbo.sp_WhoIsActive
             @sort_order           = '[start_time] ASC',
             @get_outer_command    = 1,
             @find_block_leaders   = 1,
             @get_transaction_info = 1,
             @get_locks            = 1,
             @get_task_info        = 2,
             @get_additional_info  = 1,
             @get_plans            = 1,
             @output_column_list   = '[collection_time][dd hh:mm:ss.mss][session_id][sql_text][sql_command][login_name][wait_info][tempdb_allocations][tempdb_current][blocking_session_id][blocked_session_count][reads][writes][physical_reads][used_memory][CPU][status][open_tran_count][percent_complete][host_name][database_name][program_name][locks][start_time][login_time][request_id][query_plan][additional_info]',
             @destination_table    = '#wia';

        DECLARE @HasBlocking BIT =
            CASE WHEN EXISTS (SELECT 1 FROM #wia WHERE blocking_session_id IS NOT NULL) THEN 1 ELSE 0 END;

        ------------------------------------------------------------
        -- 3. Blocking detail (old step 1)
        ------------------------------------------------------------
        IF @CaptureBlockingData = 1 AND (@HasBlocking = 1 OR @BlockingOnly = 0)
        BEGIN
            INSERT INTO dbo.Blocking_Session_History
                ([collection_time], [start_time], [session_id], [sql_text], [query_plan],
                 [wait_info], [blocking_session_id], [blocked_session_count], [additional_info])
            SELECT w.[collection_time], w.[start_time], w.[session_id], w.[sql_text], w.[query_plan],
                   w.[wait_info], w.[blocking_session_id], w.[blocked_session_count], w.[additional_info]
            FROM   #wia AS w
            WHERE  @BlockingOnly = 0
               OR  w.[blocking_session_id] IS NOT NULL
               OR  TRY_CAST(w.[blocked_session_count] AS INT) > 0;
        END;

        ------------------------------------------------------------
        -- 4. Blocking tree (old step 2 + the view), only if blocking exists
        ------------------------------------------------------------
        IF @HasBlocking = 1
        BEGIN
            ;WITH T_BLOCKERS AS
            (
                -- Block leaders
                SELECT r.[dd hh:mm:ss.mss], r.[session_id], r.[sql_command], r.[login_name], r.[wait_info],
                       r.[tempdb_allocations], r.[tempdb_current], r.[blocking_session_id], r.[blocked_session_count],
                       r.[reads], r.[writes], r.[physical_reads], r.[CPU], r.[used_memory], r.[status],
                       r.[open_tran_count], r.[percent_complete], r.[host_name], r.[database_name], r.[program_name],
                       r.[locks], r.[start_time], r.[login_time], r.[request_id], r.[collection_time],
                       [batch_text] = REPLACE(REPLACE(REPLACE(REPLACE(CAST(COALESCE(r.[sql_command], r.[sql_text]) AS VARCHAR(MAX)),
                                      CHAR(13), ''), CHAR(10), ''), '<?query --', ''), '--?>', ''),
                       [LEVEL] = CAST(RIGHT(CAST(100000 + CAST(r.[session_id] AS INT) AS VARCHAR(10)), 5) AS VARCHAR(1000))
                FROM   #wia AS r
                WHERE  (ISNULL(r.[blocking_session_id], 0) = 0 OR r.[blocking_session_id] = r.[session_id])
                  AND  EXISTS (SELECT 1
                               FROM   #wia AS r2
                               WHERE  r2.[collection_time] = r.[collection_time]
                                 AND  r2.[blocking_session_id] = r.[session_id]
                                 AND  r2.[blocking_session_id] <> r2.[session_id])

                UNION ALL

                -- Sessions blocked by the level above
                SELECT r.[dd hh:mm:ss.mss], r.[session_id], r.[sql_command], r.[login_name], r.[wait_info],
                       r.[tempdb_allocations], r.[tempdb_current], r.[blocking_session_id], r.[blocked_session_count],
                       r.[reads], r.[writes], r.[physical_reads], r.[CPU], r.[used_memory], r.[status],
                       r.[open_tran_count], r.[percent_complete], r.[host_name], r.[database_name], r.[program_name],
                       r.[locks], r.[start_time], r.[login_time], r.[request_id], r.[collection_time],
                       [batch_text] = REPLACE(REPLACE(REPLACE(REPLACE(CAST(COALESCE(r.[sql_command], r.[sql_text]) AS VARCHAR(MAX)),
                                      CHAR(13), ''), CHAR(10), ''), '<?query --', ''), '--?>', ''),
                       CAST(b.[LEVEL] + RIGHT(CAST(100000 + CAST(r.[session_id] AS INT) AS VARCHAR(10)), 5) AS VARCHAR(1000))
                FROM   #wia AS r
                INNER JOIN T_BLOCKERS AS b
                        ON r.[collection_time]    = b.[collection_time]
                       AND r.[blocking_session_id] = b.[session_id]
                WHERE  r.[blocking_session_id] <> r.[session_id]
            )
            INSERT INTO dbo.Blocking_Tree_History
            (
                [BLOCKING_TREE], [dd hh:mm:ss.mss], [wait_info], [blocked_session_count], [blocking_session_id],
                [login_name], [host_name], [database_name], [program_name], [locks],
                [tempdb_allocations], [tempdb_current], [reads], [writes], [physical_reads],
                [CPU], [used_memory], [status], [open_tran_count], [percent_complete],
                [start_time], [login_time], [request_id], [sql_command], [collection_time]
            )
            SELECT
                [BLOCKING_TREE] = N'    ' + REPLICATE(N'|         ', LEN(t.[LEVEL]) / 5 - 1)
                                + CASE WHEN LEN(t.[LEVEL]) / 5 - 1 = 0 THEN N'HEAD -  ' ELSE N'|------  ' END
                                + CAST(t.[session_id] AS NVARCHAR(10)) + N' '
                                + ISNULL(CASE WHEN LEFT(t.[batch_text], 1) = '('
                                              THEN SUBSTRING(t.[batch_text], CHARINDEX('exec', t.[batch_text]), LEN(t.[batch_text]))
                                              ELSE t.[batch_text] END, N''),
                t.[dd hh:mm:ss.mss], t.[wait_info], t.[blocked_session_count], t.[blocking_session_id],
                t.[login_name], t.[host_name], t.[database_name], t.[program_name], t.[locks],
                t.[tempdb_allocations], t.[tempdb_current], t.[reads], t.[writes], t.[physical_reads],
                t.[CPU], t.[used_memory], t.[status], t.[open_tran_count], t.[percent_complete],
                t.[start_time], t.[login_time], t.[request_id], t.[sql_command], t.[collection_time]
            FROM T_BLOCKERS AS t;
        END;

    END TRY
    BEGIN CATCH
        EXEC sys.sp_releaseapplock @Resource = N'usp_WhoIsActive_BlockingData', @LockOwner = N'Session';
        THROW;
    END CATCH;

    EXEC sys.sp_releaseapplock @Resource = N'usp_WhoIsActive_BlockingData', @LockOwner = N'Session';
END;
GO
