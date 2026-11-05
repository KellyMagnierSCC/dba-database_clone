SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_WhoIsActive_ActivityData]
(
    @CaptureReason VARCHAR(30)   = 'Scheduled',  -- 'Scheduled' | 'LogPressure' | 'Test' ...
    @CaptureDBName SYSNAME       = NULL,         -- database that triggered the capture, if any
    @CaptureDetail NVARCHAR(200) = NULL,         -- free text: why it fired, log reuse wait, etc.
    @GetPlans      BIT           = 0             -- 1 = also collect query plans (large)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @GetPlans = 1
    BEGIN
CREATE TABLE #wia_plans
(
    [collection_time]       DATETIME       NOT NULL,
    [dd hh:mm:ss.mss]       VARCHAR(8000)  NULL,
    [login_time]            DATETIME       NULL,
    [login_name]            NVARCHAR(128)  NOT NULL,
    [session_id]            SMALLINT       NOT NULL,
    [wait_info]             NVARCHAR(4000) NULL,
    [blocking_session_id]   SMALLINT       NULL,
    [blocked_session_count] VARCHAR(30)    NULL,
    [status]                VARCHAR(30)    NOT NULL,
    [open_tran_count]       VARCHAR(30)    NULL,
    [tran_start_time]       DATETIME       NULL,
    [tran_log_writes]       NVARCHAR(4000) NULL,
    [host_name]             NVARCHAR(128)  NULL,
    [database_name]         NVARCHAR(128)  NULL,
    [program_name]          NVARCHAR(128)  NULL,
    [start_time]            DATETIME       NOT NULL,
    [sql_text]              XML            NULL,
    [sql_command]           XML            NULL,
    [query_plan]            XML            NULL,
    [reads]                 VARCHAR(30)    NULL,
    [physical_reads]        VARCHAR(30)    NULL,
    [used_memory]           VARCHAR(30)    NULL,
    [CPU]                   VARCHAR(30)    NULL,
    [tempdb_allocations]    VARCHAR(30)    NULL,
    [tempdb_current]        VARCHAR(30)    NULL,
    [additional_info]       XML            NULL
);

        -- @find_block_leaders = 1 is required for blocked_session_count
        EXEC sp_WhoIsActive
             @get_transaction_info = 1,
             @find_block_leaders   = 1,
             @get_outer_command    = 1,
             @get_additional_info  = 1,
             @get_plans            = 1,
             @sort_order           = '[blocked_session_count] DESC, [session_id] ASC',
			 @output_column_list   = '[collection_time][dd hh:mm:ss.mss][login_time][login_name][session_id][wait_info][blocking_session_id][blocked_session_count][status][open_tran_count][tran_start_time][tran_log_writes][host_name][database_name][program_name][start_time][sql_text][sql_command][query_plan][reads][physical_reads][used_memory][cpu][tempdb_allocations][tempdb_current][additional_info]',
             @destination_table    = '#wia_plans';
        INSERT INTO dbo.WhoIsActive_ActivityData
        (
            [collection_time], [dd hh:mm:ss.mss], [login_time], [login_name], [session_id],
            [wait_info], [blocking_session_id], [blocked_session_count], [status], [open_tran_count],
            [tran_start_time], [tran_log_writes], [host_name], [database_name], [program_name],
            [start_time], [sql_text], [sql_command], [query_plan], [reads],
            [physical_reads], [used_memory], [CPU], [tempdb_allocations],
            [tempdb_current], [additional_info],
            [CaptureReason], [CaptureDBName], [CaptureDetail]
        )
        SELECT
            w.[collection_time], w.[dd hh:mm:ss.mss], w.[login_time], w.[login_name], w.[session_id],
            w.[wait_info], w.[blocking_session_id], w.[blocked_session_count], w.[status], w.[open_tran_count],
            w.[tran_start_time], w.[tran_log_writes], w.[host_name], w.[database_name], w.[program_name],
            w.[start_time], w.[sql_text], w.[sql_command], w.[query_plan], w.[reads],
            w.[physical_reads], w.[used_memory], w.[CPU], w.[tempdb_allocations],
            w.[tempdb_current], w.[additional_info],
            @CaptureReason, @CaptureDBName, @CaptureDetail
        FROM #wia_plans AS w;
    END
    ELSE
    BEGIN
        CREATE TABLE #wia
        (
            [collection_time]       DATETIME       NOT NULL,
            [dd hh:mm:ss.mss]       VARCHAR(8000)  NULL,
            [login_time]            DATETIME       NULL,
            [login_name]            NVARCHAR(128)  NOT NULL,
            [session_id]            SMALLINT       NOT NULL,
            [wait_info]             NVARCHAR(4000) NULL,
            [blocking_session_id]   SMALLINT       NULL,
            [blocked_session_count] VARCHAR(30)    NULL,
            [status]                VARCHAR(30)    NOT NULL,
            [open_tran_count]       VARCHAR(30)    NULL,
            [tran_start_time]       DATETIME       NULL,
            [tran_log_writes]       NVARCHAR(4000) NULL,
            [host_name]             NVARCHAR(128)  NULL,
            [database_name]         NVARCHAR(128)  NULL,
            [program_name]          NVARCHAR(128)  NULL,
            [start_time]            DATETIME       NOT NULL,
            [sql_text]              XML            NULL,
            [sql_command]           XML            NULL,
            [reads]                 VARCHAR(50)    NULL,
            [physical_reads]        VARCHAR(50)    NULL,
            [used_memory]           VARCHAR(50)    NULL,
            [CPU]                   VARCHAR(50)    NULL,
            [tempdb_allocations]    VARCHAR(50)    NULL,
            [tempdb_current]        VARCHAR(50)    NULL,
            [additional_info]       XML            NULL
        );

        EXEC sp_WhoIsActive
             @get_transaction_info = 1,
             @find_block_leaders   = 1,
             @get_outer_command    = 1,
             @get_additional_info  = 1,
             @sort_order           = '[blocked_session_count] DESC, [session_id] ASC',
             @output_column_list   = '[collection_time][dd hh:mm:ss.mss][login_time][login_name][session_id][wait_info][blocking_session_id][blocked_session_count][status][open_tran_count][tran_start_time][tran_log_writes][host_name][database_name][program_name][start_time][sql_text][sql_command][reads][physical_reads][used_memory][cpu][tempdb_allocations][tempdb_current][additional_info]',
             @destination_table    = '#wia';

        INSERT INTO dbo.WhoIsActive_ActivityData
        (
            [collection_time], [dd hh:mm:ss.mss], [login_time], [login_name], [session_id],
            [wait_info], [blocking_session_id], [blocked_session_count], [status], [open_tran_count],
            [tran_start_time], [tran_log_writes], [host_name], [database_name], [program_name],
            [start_time], [sql_text], [sql_command], [query_plan], [reads],
            [physical_reads], [used_memory], [CPU], [tempdb_allocations],
            [tempdb_current], [additional_info],
            [CaptureReason], [CaptureDBName], [CaptureDetail]
        )
        SELECT
            w.[collection_time], w.[dd hh:mm:ss.mss], w.[login_time], w.[login_name], w.[session_id],
            w.[wait_info], w.[blocking_session_id], w.[blocked_session_count], w.[status], w.[open_tran_count],
            w.[tran_start_time], w.[tran_log_writes], w.[host_name], w.[database_name], w.[program_name],
            w.[start_time], w.[sql_text], w.[sql_command], NULL, w.[reads],
            w.[physical_reads], w.[used_memory], w.[CPU], w.[tempdb_allocations],
            w.[tempdb_current], w.[additional_info],
            @CaptureReason, @CaptureDBName, @CaptureDetail
        FROM #wia AS w;
    END;
END;

GO

