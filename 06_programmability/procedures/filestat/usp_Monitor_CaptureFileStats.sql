SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureFileStats]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.FileStat_Drive_History
        (capture_time, [Drive], [Volume Mount Point], [Read Latency], [Write Latency], [Overall Latency],
         [Avg Bytes/Read], [Avg Bytes/Write], [Avg Bytes/Transfer])
    SELECT GETDATE(), [Drive], [Volume Mount Point], [Read Latency], [Write Latency], [Overall Latency],
           [Avg Bytes/Read], [Avg Bytes/Write], [Avg Bytes/Transfer]
    FROM dbo.vw_FileStat_Drive_Current;

    INSERT INTO dbo.FileStat_Database_History
        (capture_time, [Database Name], [avg_read_latency_ms], [avg_write_latency_ms], [avg_io_latency_ms],
         [File Size (MB)], physical_name, type_desc, io_stall_read_ms, num_of_reads, io_stall_write_ms,
         num_of_writes, io_stalls, total_io,
         [Resource Governor Total Read IO Latency (ms)], [Resource Governor Total Write IO Latency (ms)])
    SELECT GETDATE(), [Database Name], [avg_read_latency_ms], [avg_write_latency_ms], [avg_io_latency_ms],
           [File Size (MB)], physical_name, type_desc, io_stall_read_ms, num_of_reads, io_stall_write_ms,
           num_of_writes, io_stalls, total_io,
           [Resource Governor Total Read IO Latency (ms)], [Resource Governor Total Write IO Latency (ms)]
    FROM dbo.vw_FileStat_Database_Current;
END
GO
