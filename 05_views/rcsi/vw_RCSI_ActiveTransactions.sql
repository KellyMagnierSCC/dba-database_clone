SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    



CREATE OR ALTER VIEW [dbo].[vw_RCSI_ActiveTransactions]
AS
SELECT
    at.transaction_id,
    at.session_id,
    at.is_snapshot,
    at.elapsed_time_seconds,
    es.login_name,
    es.host_name,
    es.program_name,
    es.status,
    DB_NAME(dt.database_id) AS database_name
FROM sys.dm_tran_active_snapshot_database_transactions AS at
JOIN sys.dm_exec_sessions AS es
    ON at.session_id = es.session_id
JOIN sys.dm_tran_database_transactions AS dt
    ON at.transaction_id = dt.transaction_id;
GO
