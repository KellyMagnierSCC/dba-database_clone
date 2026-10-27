SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [dbo].[vw_FileStat_Database_Spikes]
AS
SELECT TOP 100 PERCENT
    capture_time,
    [Database Name],
    physical_name,
    [avg_io_latency_ms],
    [avg_io_latency_ms] - LAG([avg_io_latency_ms]) OVER (PARTITION BY [Database Name], physical_name ORDER BY capture_time) AS delta_latency
FROM dbo.FileStat_Database_History
ORDER BY delta_latency DESC;
GO
