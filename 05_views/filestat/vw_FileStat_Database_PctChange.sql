SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [dbo].[vw_FileStat_Database_PctChange]
AS
SELECT
    capture_time,
    [Database Name],
    physical_name,
    [avg_io_latency_ms],
    100.0 * ([avg_io_latency_ms] - LAG([avg_io_latency_ms]) OVER (PARTITION BY [Database Name], physical_name ORDER BY capture_time))
           / NULLIF(LAG([avg_io_latency_ms]) OVER (PARTITION BY [Database Name], physical_name ORDER BY capture_time),0) AS pct_change_latency
FROM dbo.FileStat_Database_History
--ORDER BY [Database Name], physical_name, capture_time;
GO
