SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- One row per capture in WaitStats_Capture_History: when it ran, how long since the previous one, and
-- whether the wait counters were reset in between. vw_WaitStats_Delta, and any view that needs
-- to know how much time the captures cover, reads from here.
--
-- How resets are detected
--   sys.dm_os_wait_stats is cumulative: it only goes up until the instance restarts or someone
--   runs DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR). A capture is a reset when any wait type's
--   counter (benign ones included) is lower than at its previous capture, because a cumulative
--   counter can't go down otherwise. Comparing per wait type means that capturing fewer wait
--   types (a change to vw_WaitStats_Current's filter) is not mistaken for a reset.
--   period_num counts the resets so far: rows with the same period_num can be compared safely.
--
-- One capture = one capture_time: the column default is evaluated once per INSERT.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_Captures]
AS
WITH WaitSteps AS
(
    SELECT
        capture_time,
        CASE WHEN wait_time_ms        < LAG(wait_time_ms)        OVER (PARTITION BY wait_type ORDER BY capture_time)
               OR waiting_tasks_count < LAG(waiting_tasks_count) OVER (PARTITION BY wait_type ORDER BY capture_time)
             THEN 1 ELSE 0 END AS went_down
    FROM dbo.WaitStats_Capture_History
),
Captures AS
(
    SELECT
        capture_time,
        COUNT(*)       AS wait_types_captured,
        MAX(went_down) AS is_reset
    FROM WaitSteps
    GROUP BY capture_time
)
SELECT
    capture_time,
    LAG(capture_time) OVER (ORDER BY capture_time)                                    AS prev_capture_time,
    DATEDIFF(SECOND, LAG(capture_time) OVER (ORDER BY capture_time), capture_time)   AS interval_seconds,
    is_reset,
    SUM(is_reset) OVER (ORDER BY capture_time ROWS UNBOUNDED PRECEDING)              AS period_num,
    wait_types_captured
FROM Captures;
GO
