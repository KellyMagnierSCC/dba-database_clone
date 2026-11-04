SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- What's creeping up? One row per day per wait type, for every non-benign wait (not just the
-- top 5), compared with the 7 days before it.
--
-- Compare days by wait_ms_per_sec, not by wait_time_ms: it divides by the seconds the captures
-- actually covered that day, so today (a part day) and days with missed captures compare fairly.
--
-- prev7_avg_wait_ms_per_sec is the average over the previous 7 days that have captures (a day
-- with no captures at all is skipped, not counted as zero; a day with captures but none of this
-- wait counts as zero). prev7_days says how many days the average is based on.
-- had_reset = 1 when the counters were reset that day: the waits just before the reset are lost.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_DailyTrend]
AS
WITH Coverage AS
(
    SELECT
        CAST(capture_time AS date) AS capture_date,
        COUNT(*)                   AS captures,
        SUM(interval_seconds)      AS captured_seconds,
        MAX(is_reset)              AS had_reset
    FROM dbo.vw_WaitStats_Captures
    WHERE prev_capture_time IS NOT NULL
    GROUP BY CAST(capture_time AS date)
),
DayTotals AS
(
    SELECT
        CAST(capture_time AS date)     AS capture_date,
        wait_type,
        SUM(delta_waiting_tasks)       AS waiting_tasks,
        SUM(delta_wait_time_ms)        AS wait_time_ms,
        SUM(delta_signal_wait_time_ms) AS signal_wait_time_ms
    FROM dbo.vw_WaitStats_Delta
    GROUP BY CAST(capture_time AS date), wait_type
),
WaitTypes AS
(
    SELECT DISTINCT wait_type FROM DayTotals
),
Grid AS
(
    -- Every captured day for every wait type, so a day without the wait counts as zero
    SELECT
        c.capture_date,
        w.wait_type,
        c.captures,
        c.captured_seconds,
        c.had_reset,
        ISNULL(t.waiting_tasks, 0)       AS waiting_tasks,
        ISNULL(t.wait_time_ms, 0)        AS wait_time_ms,
        ISNULL(t.signal_wait_time_ms, 0) AS signal_wait_time_ms,
        ISNULL(t.wait_time_ms, 0) * 1.0 / NULLIF(c.captured_seconds, 0) AS wait_ms_per_sec
    FROM Coverage AS c
    CROSS JOIN WaitTypes AS w
    LEFT JOIN DayTotals AS t
        ON  t.capture_date = c.capture_date
        AND t.wait_type    = w.wait_type
),
Trend AS
(
    SELECT
        g.*,
        AVG(wait_ms_per_sec) OVER (PARTITION BY wait_type ORDER BY capture_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS prev7_avg_wait_ms_per_sec,
        COUNT(*)             OVER (PARTITION BY wait_type ORDER BY capture_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS prev7_days
    FROM Grid AS g
)
SELECT
    capture_date,
    wait_type,
    captures,
    captured_seconds,
    had_reset,
    waiting_tasks,
    wait_time_ms,
    signal_wait_time_ms,
    wait_time_ms - signal_wait_time_ms                                         AS resource_wait_time_ms,
    CAST(wait_time_ms * 1.0 / NULLIF(waiting_tasks, 0) AS decimal(19,3))       AS avg_wait_ms_per_task,
    CAST(wait_ms_per_sec AS decimal(19,3))                                     AS wait_ms_per_sec,
    CAST(prev7_avg_wait_ms_per_sec AS decimal(19,3))                           AS prev7_avg_wait_ms_per_sec,
    prev7_days,
    CAST(100.0 * (wait_ms_per_sec - prev7_avg_wait_ms_per_sec)
         / NULLIF(prev7_avg_wait_ms_per_sec, 0) AS decimal(19,1))              AS pct_change_vs_prev7
FROM Trend
WHERE wait_time_ms > 0
   OR waiting_tasks > 0
   OR prev7_avg_wait_ms_per_sec > 0;
GO
