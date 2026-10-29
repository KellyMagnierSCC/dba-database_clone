SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureLogGrowth]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CurrentFile nvarchar(260),
            @Separator   nchar(1),
            @TracePath   nvarchar(260);

    SELECT @CurrentFile = path
    FROM sys.traces
    WHERE is_default = 1;

    IF @CurrentFile IS NULL
        THROW 50001, N'The default trace is disabled, so log growth events cannot be captured. Enable it with sp_configure ''default trace enabled'', 1.', 1;

    -- sys.traces gives the current rollover file, e.g. ...\log_123.trc. Reading from ...\log.trc
    -- makes fn_trace_gettable read every rollover file still on disk, not just the current one.
    SET @Separator = CASE WHEN CHARINDEX(N'\', @CurrentFile) > 0 THEN N'\' ELSE N'/' END;
    SET @TracePath = LEFT(@CurrentFile, LEN(@CurrentFile) - CHARINDEX(@Separator, REVERSE(@CurrentFile)) + 1) + N'log.trc';

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.LogGrowth_History
        (
            DatabaseName,
            LogicalFileName,
            EventStartTime,
            EventEndTime,
            DurationSec,
            GrowthMB
        )
        SELECT
            ISNULL(t.DatabaseName, DB_NAME(t.DatabaseID)),
            ISNULL(t.FileName, N''),
            t.StartTime,
            t.EndTime,
            CAST(t.Duration / 1000000.0 AS decimal(10, 3)),   -- Duration is in microseconds
            CAST(t.IntegerData * 8.0 / 1024 AS decimal(12, 2)) -- IntegerData is the growth in 8 KB pages
        FROM sys.fn_trace_gettable(@TracePath, DEFAULT) AS t
        WHERE t.EventClass = 93                               -- Log File Auto Grow only; data file growth belongs to filestat
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.LogGrowth_History AS g
              WHERE g.DatabaseName = ISNULL(t.DatabaseName, DB_NAME(t.DatabaseID))
                AND g.LogicalFileName = ISNULL(t.FileName, N'')
                AND g.EventStartTime = t.StartTime
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
