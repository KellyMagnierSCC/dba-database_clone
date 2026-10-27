SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_RCSI_VersionStore_Sessions]
AS
WITH SnapshotSessions AS
(
    SELECT
        t.session_id,
        s.login_name,
        s.host_name,
        s.program_name,
        s.status,
        s.last_request_start_time,
        s.last_request_end_time,
        r.start_time AS request_start_time,
        r.cpu_time,
        r.total_elapsed_time,
        st.text AS sql_text,
        --DB_NAME(st.dbid) AS inferred_database
		        -- Infer database with fallback
        COALESCE(
            DB_NAME(st.dbid),         -- try SQL text dbid first
            DB_NAME(r.database_id),   -- then active request database_id
            DB_NAME(s.database_id),         -- then sysprocesses dbid
            'UNKNOWN'                 -- fallback if all null
        ) AS inferred_database
    FROM sys.dm_tran_active_snapshot_database_transactions t
    JOIN sys.dm_exec_sessions s
        ON t.session_id = s.session_id
    LEFT JOIN sys.dm_exec_requests r
        ON t.session_id = r.session_id
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
)
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    inferred_database,
    sql_text,
    last_request_start_time,
    last_request_end_time,
    request_start_time,
    cpu_time,
    total_elapsed_time,
    DATEDIFF(MINUTE, ISNULL(request_start_time, last_request_start_time), GETDATE()) AS approx_transaction_age_min
FROM SnapshotSessions
--ORDER BY approx_transaction_age_min DESC;
GO
