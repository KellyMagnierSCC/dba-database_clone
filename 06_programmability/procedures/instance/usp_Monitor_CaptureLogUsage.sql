SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureLogUsage]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- One row per online database. sys.dm_db_log_stats covers every database in one query,
        -- with no dynamic SQL, and returns one row per database however many log files it has.
        INSERT INTO dbo.LogUsage_History
        (
            DatabaseName,
            RecoveryModel,
            TotalLogSizeMB,
            ActiveLogSizeMB,
            PercentActive,
            TotalVlfCount,
            ActiveVlfCount,
            LogTruncationHoldupReason,
            LastLogBackupTime,
            OldestOpenTranBeginTime,
            OldestOpenTranAgeSec,
            OldestOpenTranSessionID
        )
        SELECT
            d.name,
            d.recovery_model_desc,
            CAST(ls.total_log_size_mb AS decimal(18, 2)),
            CAST(ls.active_log_size_mb AS decimal(18, 2)),
            CAST(CASE WHEN ls.total_log_size_mb > 0
                      THEN ls.active_log_size_mb * 100.0 / ls.total_log_size_mb
                      ELSE 0 END AS decimal(5, 2)),
            ls.total_vlf_count,
            ls.active_vlf_count,
            ls.log_truncation_holdup_reason,
            NULLIF(ls.log_backup_time, '19000101'),           -- 1900-01-01 means no log backup yet
            ot.BeginTime,
            DATEDIFF(SECOND, ot.BeginTime, GETDATE()),
            ot.SessionID
        FROM sys.databases AS d
        CROSS APPLY sys.dm_db_log_stats(d.database_id) AS ls
        OUTER APPLY
        (
            -- The oldest open transaction in THIS database, and the session that owns it
            SELECT TOP (1)
                dt.database_transaction_begin_time AS BeginTime,
                st.session_id AS SessionID
            FROM sys.dm_tran_database_transactions AS dt
            JOIN sys.dm_tran_session_transactions AS st
                ON st.transaction_id = dt.transaction_id
            WHERE dt.database_id = d.database_id
              AND dt.database_transaction_begin_time IS NOT NULL
            ORDER BY dt.database_transaction_begin_time
        ) AS ot
        WHERE d.state_desc = N'ONLINE'
          AND d.source_database_id IS NULL                    -- skip database snapshots
	  AND d.database_id > 4 			      -- skip system databases
          AND HAS_DBACCESS(d.name) = 1;                       -- skip databases this login can't open

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
