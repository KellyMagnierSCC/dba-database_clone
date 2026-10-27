SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_Query_Transactions]
as
SELECT
    at.transaction_id,
    at.name AS transaction_name,
    at.transaction_begin_time,
    at.transaction_state,
    at.transaction_status,
    at.transaction_type,
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    r.status AS request_status,
    r.command,
    r.wait_type,
    r.blocking_session_id,
    r.cpu_time,
    r.total_elapsed_time,
    st.text AS running_sql_text
FROM sys.dm_tran_active_transactions at
JOIN sys.dm_tran_session_transactions stx ON at.transaction_id = stx.transaction_id
JOIN sys.dm_exec_sessions s ON stx.session_id = s.session_id
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE at.transaction_type = 1 -- 1 = Read/write transaction
GO
