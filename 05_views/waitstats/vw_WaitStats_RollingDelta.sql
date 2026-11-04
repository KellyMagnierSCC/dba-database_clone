SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Each wait type's cumulative counters at every capture, next to the change since the previous
-- capture. The deltas come from vw_WaitStats_Delta, so they are never negative after a restart.
-- Like vw_WaitStats_Delta, it leaves out benign waits, the first capture, and rows where nothing
-- changed. For new work, vw_WaitStats_Delta has more columns (interval, rate, reset flag).
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_RollingDelta]
AS
SELECT
    d.capture_time,
    d.wait_type,
    h.wait_time_ms,
    h.signal_wait_time_ms,
    h.waiting_tasks_count,
    d.delta_wait_time_ms,
    d.delta_signal_wait_time_ms,
    d.delta_waiting_tasks
FROM dbo.vw_WaitStats_Delta AS d
JOIN dbo.WaitStats_Capture_History AS h
    ON  h.capture_time = d.capture_time
    AND h.wait_type    = d.wait_type;
GO
