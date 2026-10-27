SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Alert: emails a report when any transaction has been open longer than @TransactionThreshold
-- seconds. Writes nothing. Formerly usp_CheckActiveTransactionAlert.
-- SQLText is the session's most recent batch (first 800 characters), which is not necessarily the
-- statement that opened the transaction. It can contain literal data values, and it is emailed.
CREATE OR ALTER PROCEDURE [dbo].[usp_Alert_LongRunningTransactions]
    @TransactionThreshold int           = 7200,   -- seconds; 2 hours
    @EmailRecipients      nvarchar(500) = N'dba.alerts@surreycc.gov.uk',
    @MailProfile          sysname       = N'Database Monitoring'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Server      sysname       = @@SERVERNAME;
    DECLARE @Database    sysname       = DB_NAME();
    DECLARE @SubjectLine nvarchar(300) = CONCAT(N'Active Transaction Threshold Exceeded Alert - ', @Server);

    -- The check and the emailed report read the same view, so an alert always has rows attached
    DECLARE @QueryString nvarchar(max) = CONCAT(N'SET QUOTED_IDENTIFIER ON;
SELECT [Elapsed_Time_Mins], [session_id], [transaction_begin_time], [login_time], [host_name],
       [status], [Database_Name], [Affecting_TLOG], [Percentage_Log_Used],
       REPLACE(REPLACE(REPLACE([SQLText], CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '') AS [SQLText]
FROM dbo.vw_Query_ActiveTransactionsAlert
WHERE tran_elapsed_time_seconds > ', @TransactionThreshold, N'
ORDER BY tran_elapsed_time_seconds DESC;');

    IF EXISTS (
        SELECT 1
        FROM dbo.vw_Query_ActiveTransactionsAlert
        WHERE tran_elapsed_time_seconds > @TransactionThreshold
    )
    BEGIN
        PRINT N'Active Transactions over Threshold Value';

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name                = @MailProfile,
            @recipients                  = @EmailRecipients,
            @subject                     = @SubjectLine,
            @body                        = N'There are active sessions that have been executing over the threshold. Check the attached report and investigate.',
            @body_format                 = 'HTML',
            @execute_query_database      = @Database,
            @query                       = @QueryString,
            @query_result_width          = 10000,
            @query_attachment_filename   = 'Active_Sessions_Over_Threshold.rpt',
            @importance                  = 'High',
            @exclude_query_output        = 1,
            @attach_query_result_as_file = 1;
    END
    ELSE
        PRINT N'No Active Transactions Exceeding Threshold';
END;
GO
