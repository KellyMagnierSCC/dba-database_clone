SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- One row per wait type per capture: what changed since the previous capture.
-- WaitStats_Capture_History holds the cumulative counters from sys.dm_os_wait_stats.
--
-- How resets are handled
--   vw_WaitStats_Captures flags each capture where the counters were reset (restart or
--   DBCC SQLPERF ... CLEAR) and numbers the periods between resets. Deltas are only taken within
--   a period, so they are never negative. The first row of a wait type in a period counts from
--   zero: after a reset that is the wait counted since the reset (the waits between the previous
--   capture and the reset are lost, and is_reset = 1 marks the row). A wait type that appears
--   for the first time also counts from zero.
--
-- Columns
--   interval_seconds   seconds since the previous capture. If the job missed runs, this is
--                      longer than usual: use wait_ms_per_sec to compare intervals
--   wait_ms_per_sec    delta wait time per second of interval: the fair way to compare
--   resource wait      wait time minus signal wait (time waiting for the resource itself)
--   max_wait_time_ms   the cumulative high-water mark as captured, not a delta
--
-- Left out: benign waits (vw_WaitStats_BenignWaits), the first capture in the table (nothing
-- to compare it with), and rows where nothing changed.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_Delta]
AS
WITH WaitRows AS
(
    SELECT
        h.capture_time,
        c.prev_capture_time,
        c.interval_seconds,
        c.is_reset,
        h.wait_type,
        h.waiting_tasks_count,
        h.wait_time_ms,
        h.signal_wait_time_ms,
        h.max_wait_time_ms,
        LAG(h.waiting_tasks_count, 1, 0) OVER (PARTITION BY h.wait_type, c.period_num ORDER BY h.capture_time) AS prev_waiting_tasks_count,
        LAG(h.wait_time_ms, 1, 0)        OVER (PARTITION BY h.wait_type, c.period_num ORDER BY h.capture_time) AS prev_wait_time_ms,
        LAG(h.signal_wait_time_ms, 1, 0) OVER (PARTITION BY h.wait_type, c.period_num ORDER BY h.capture_time) AS prev_signal_wait_time_ms
    FROM dbo.WaitStats_Capture_History AS h
    JOIN dbo.vw_WaitStats_Captures AS c
        ON c.capture_time = h.capture_time
    WHERE h.wait_type NOT IN (SELECT b.wait_type FROM dbo.vw_WaitStats_BenignWaits AS b)
),
Deltas AS
(
    SELECT
        capture_time,
        prev_capture_time,
        interval_seconds,
        is_reset,
        wait_type,
        waiting_tasks_count - prev_waiting_tasks_count AS delta_waiting_tasks,
        wait_time_ms        - prev_wait_time_ms        AS delta_wait_time_ms,
        signal_wait_time_ms - prev_signal_wait_time_ms AS delta_signal_wait_time_ms,
        max_wait_time_ms
    FROM WaitRows
    WHERE prev_capture_time IS NOT NULL
)
SELECT
    capture_time,
    prev_capture_time,
    interval_seconds,
    is_reset,
    wait_type,
    delta_waiting_tasks,
    delta_wait_time_ms,
    delta_signal_wait_time_ms,
    delta_wait_time_ms - delta_signal_wait_time_ms                                    AS delta_resource_wait_time_ms,
    CAST(delta_wait_time_ms * 1.0 / NULLIF(interval_seconds, 0) AS decimal(19,3))    AS wait_ms_per_sec,
    CAST(delta_wait_time_ms * 1.0 / NULLIF(delta_waiting_tasks, 0) AS decimal(19,3)) AS avg_wait_ms_per_task,
    max_wait_time_ms
FROM Deltas
WHERE delta_waiting_tasks > 0
   OR delta_wait_time_ms > 0;
GO
