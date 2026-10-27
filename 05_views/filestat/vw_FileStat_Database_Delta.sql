SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [dbo].[vw_FileStat_Database_Delta]
AS
SELECT
    capture_time,
    [Database Name],
    physical_name,
    [avg_read_latency_ms],
    [avg_write_latency_ms],
    [avg_io_latency_ms],
    [File Size (MB)],
    [io_stall_read_ms],
    [num_of_reads],
    [io_stall_write_ms],
    [num_of_writes],
    [io_stalls],
    [total_io],
    [Resource Governor Total Read IO Latency (ms)],
    [Resource Governor Total Write IO Latency (ms)],
    [avg_read_latency_ms] - LAG([avg_read_latency_ms]) OVER (PARTITION BY [Database Name], physical_name ORDER BY capture_time) AS delta_read_latency,
    [avg_write_latency_ms] - LAG([avg_write_latency_ms]) OVER (PARTITION BY [Database Name], physical_name ORDER BY capture_time) AS delta_write_latency,
    [avg_io_latency_ms] - LAG([avg_io_latency_ms]) OVER (PARTITION BY [Database Name], physical_name ORDER BY capture_time) AS delta_total_latency
FROM dbo.FileStat_Database_History
--ORDER BY [Database Name], physical_name, capture_time;
GO
