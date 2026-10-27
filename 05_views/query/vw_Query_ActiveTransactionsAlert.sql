SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Cross-domain dependency: reads dbo.vw_Instance_ActiveTransactions (domain: instance)
-- Cross-domain dependency: reads dbo.vw_Instance_LogFile_Usage (domain: instance)
CREATE OR ALTER VIEW [dbo].[vw_Query_ActiveTransactionsAlert] as
SELECT 
                    tran_elapsed_time_seconds,
                    tran_elapsed_time_seconds / 60 AS Elapsed_Time_Mins,
                    session_id,
                    transaction_begin_time,
                    login_time,
                    cast(host_name as varchar(20)) as host_name,
                    status,
                    cast(DB_NAME(database_id) as varchar(30)) AS Database_Name,
                    CASE
                        WHEN log_truncation_holdup_reason IS NULL THEN 'Log Reuse not Affected'
                        ELSE 'Possible Cause of Log Reuse Issue'
                    END AS Affecting_TLOG,
                    percentage_in_use AS Percentage_Log_Used,
                    cast([text] as varchar(800)) AS SQLText
FROM [dbo].[vw_Instance_ActiveTransactions] IAT
LEFT OUTER JOIN [dbo].[vw_Instance_LogFile_Usage] ILU
ON DB_NAME(IAT.database_id) = ILU.[Database Name]
AND ILU.log_truncation_holdup_reason = 'ACTIVE_TRANSACTION'
              

GO
