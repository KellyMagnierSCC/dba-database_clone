SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Alert: emails when the average total CPU (SQL Server + other processes) over the 10 most
-- recent one-minute ring-buffer readings exceeds @cpuThreshold. Writes nothing.
-- Formerly usp_CheckHighCPUAlert.
CREATE OR ALTER PROCEDURE [dbo].[usp_Alert_HighCpu]
    @cpuThreshold    int           = 80,
    @EmailRecipients nvarchar(500) = N'dba.alerts@surreycc.gov.uk',
    @MailProfile     sysname       = N'Database Monitoring'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AvgSQLCPU    int;
    DECLARE @AvgNonSQLCPU int;
    DECLARE @AvgTotalCPU  int;
    DECLARE @Server       sysname       = @@SERVERNAME;
    DECLARE @Database     sysname       = DB_NAME();
    DECLARE @SubjectLine  nvarchar(300) = CONCAT(N'High CPU Utilisation Alert - ', @Server);

    -- Average of the 10 most recent readings (the view returns one reading per minute)
    WITH TopCPU AS
    (
        SELECT TOP (10)
            [SQL Server Process CPU Utilization] AS TopSQLCPU,
            [Other Process CPU Utilization]      AS TopNonSQLCPU
        FROM dbo.vw_CPU_UtilLast256Min
        ORDER BY [Event Time] DESC
    )
    SELECT
        @AvgSQLCPU    = AVG(TopSQLCPU),
        @AvgNonSQLCPU = AVG(TopNonSQLCPU)
    FROM TopCPU;

    SET @AvgTotalCPU = @AvgSQLCPU + @AvgNonSQLCPU;

    PRINT CONCAT(N'Average CPU - ', @AvgTotalCPU, N'%');

    IF @AvgTotalCPU > @cpuThreshold
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail
            @profile_name                = @MailProfile,
            @recipients                  = @EmailRecipients,
            @subject                     = @SubjectLine,
            @body                        = N'The average CPU utilisation of the last 10 minutes exceeds the threshold. Check the attached report and investigate.',
            @body_format                 = 'HTML',
            @execute_query_database      = @Database,
            @query                       = N'SET QUOTED_IDENTIFIER ON; SELECT * FROM dbo.vw_CPU_UtilLast256Min ORDER BY [Event Time] DESC;',
            @query_result_width          = 3000,
            @query_attachment_filename   = 'CPU Utilisation.rpt',
            @importance                  = 'High',
            @exclude_query_output        = 1,
            @attach_query_result_as_file = 1;
    END;
END;
GO
