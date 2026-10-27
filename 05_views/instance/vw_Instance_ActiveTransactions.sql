SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_Instance_ActiveTransactions]
as
--Gets a list of active transactions on the instance
--Useful  when trying to determine why a log wont shrink due to active transactions
SELECT Getdate()                                           AS now,
       Datediff(second, transaction_begin_time, Getdate()) AS
       tran_elapsed_time_seconds,
       st.session_id,
       txt.text,
       transaction_begin_time,
       is_user_transaction,
       st.open_transaction_count,
       login_time,
       host_name,
       status,
       last_request_start_time,
       last_request_end_time,
       database_id,
       last_read,
       last_write,
       client_tcp_port
FROM   sys.dm_tran_active_transactions at
       INNER JOIN sys.dm_tran_session_transactions st
               ON st.transaction_id = at.transaction_id
       LEFT OUTER JOIN sys.dm_exec_sessions sess
                    ON st.session_id = sess.session_id
       LEFT OUTER JOIN sys.dm_exec_connections conn
                    ON conn.session_id = sess.session_id
       OUTER apply sys.Dm_exec_sql_text(conn.most_recent_sql_handle) AS txt

GO
