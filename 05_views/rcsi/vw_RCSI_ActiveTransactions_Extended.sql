SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_RCSI_ActiveTransactions_Extended]
AS
SELECT
    at.transaction_id,
    at.session_id,
    at.is_snapshot,
    at.elapsed_time_seconds,
    es.login_name,
    es.host_name,
    es.program_name,
    es.status AS session_status,
    dt.database_id,
    DB_NAME(dt.database_id) AS database_name,
    r.status AS request_status,
    r.command,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.last_wait_type,
    r.cpu_time,
    r.total_elapsed_time,
    st.text AS sql_text
FROM sys.dm_tran_active_snapshot_database_transactions AS at
JOIN sys.dm_exec_sessions AS es
    ON at.session_id = es.session_id
JOIN sys.dm_tran_database_transactions AS dt
    ON at.transaction_id = dt.transaction_id
LEFT JOIN sys.dm_exec_requests AS r
    ON at.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st;
GO
