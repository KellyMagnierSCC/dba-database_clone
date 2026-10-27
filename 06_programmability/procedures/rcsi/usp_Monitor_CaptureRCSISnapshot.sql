SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureRCSISnapshot]
AS
BEGIN
    SET NOCOUNT ON;

    -- Active transactions
    INSERT INTO dbo.RCSI_ActiveTransactions_History
    (
        transaction_id, session_id, is_snapshot, elapsed_time_seconds,
        login_name, host_name, program_name, status, database_name
    )
	SELECT
        at.transaction_id,
        at.session_id,
        at.is_snapshot,
        at.elapsed_time_seconds,
        es.login_name,
        es.host_name,
        es.program_name,
        es.status,
        DB_NAME(dt.database_id)
    FROM sys.dm_tran_active_snapshot_database_transactions AS at
    JOIN sys.dm_exec_sessions AS es
        ON at.session_id = es.session_id
    JOIN sys.dm_tran_database_transactions AS dt
        ON at.transaction_id = dt.transaction_id;

    -- Version store usage
    INSERT INTO dbo.RCSI_VersionStoreUsage_History (database_name, version_store_mb)
    SELECT
        DB_NAME(database_id),
        reserved_page_count * 8 / 1024.0
    FROM sys.dm_tran_version_store_space_usage;

    -- Tempdb usage
    INSERT INTO dbo.RCSI_TempdbUsage_History (mb_user_objects, mb_internal, mb_version_store, mb_free)
    SELECT
        SUM(user_object_reserved_page_count) * 8 / 1024.0,
        SUM(internal_object_reserved_page_count) * 8 / 1024.0,
        SUM(version_store_reserved_page_count) * 8 / 1024.0,
        SUM(unallocated_extent_page_count) * 8 / 1024.0
    FROM tempdb.sys.dm_db_file_space_usage;

	--Active Transaction Extended
	    INSERT INTO dbo.RCSI_ActiveTransactions_Extended_History (
        capture_time,
        transaction_id,
        session_id,
        is_snapshot,
        elapsed_time_seconds,
        login_name,
        host_name,
        program_name,
        session_status,
        database_id,
        database_name,
        request_status,
        command,
        blocking_session_id,
        wait_type,
        wait_time,
        last_wait_type,
        cpu_time,
        total_elapsed_time,
        sql_text
    )
    SELECT
        GETDATE(),
        transaction_id,
        session_id,
        is_snapshot,
        elapsed_time_seconds,
        login_name,
        host_name,
        program_name,
        session_status,
        database_id,
        database_name,
        request_status,
        command,
        blocking_session_id,
        wait_type,
        wait_time,
        last_wait_type,
        cpu_time,
        total_elapsed_time,
        sql_text
    FROM dbo.vw_RCSI_ActiveTransactions_Extended;

END;
GO
