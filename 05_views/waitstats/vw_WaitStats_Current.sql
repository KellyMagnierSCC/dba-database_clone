SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- The current cumulative wait counters, without benign waits. usp_Monitor_CaptureWaitStats
-- stores this every 5 minutes. The benign-wait list is the shared one in vw_WaitStats_BenignWaits.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_Current]
AS
SELECT
    ws.wait_type,
    ws.waiting_tasks_count,
    ws.wait_time_ms,
    ws.max_wait_time_ms,
    ws.signal_wait_time_ms
FROM sys.dm_os_wait_stats AS ws
-- COLLATE: the DMV uses the server's collation, the list uses the database's, and they can differ
WHERE ws.wait_type COLLATE DATABASE_DEFAULT NOT IN (SELECT b.wait_type FROM dbo.vw_WaitStats_BenignWaits AS b);
GO
