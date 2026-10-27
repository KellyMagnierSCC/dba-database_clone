SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [dbo].[vw_FileStat_Database_RollingAvg]
AS
SELECT
    capture_time,
    [Database Name],
    physical_name,
    [avg_io_latency_ms],
    AVG([avg_io_latency_ms]) OVER (
        PARTITION BY [Database Name], physical_name
        ORDER BY capture_time
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_io_latency
FROM dbo.FileStat_Database_History
--ORDER BY [Database Name], physical_name, capture_time;
GO
