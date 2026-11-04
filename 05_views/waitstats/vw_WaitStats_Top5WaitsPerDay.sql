SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- The 5 biggest waits per day, by total wait time, with each one's share of the day's total.
-- Reads vw_WaitStats_Delta, which removes benign waits and handles counter resets: after a
-- restart, the waits counted since the restart are included instead of the interval being lost.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_Top5WaitsPerDay]
AS
WITH DailyTotals AS
(
    SELECT
        CAST(capture_time AS date) AS capture_date,
        wait_type,
        SUM(delta_wait_time_ms)    AS total_wait_ms
    FROM dbo.vw_WaitStats_Delta
    WHERE delta_wait_time_ms > 0
    GROUP BY CAST(capture_time AS date), wait_type
),
RankedWaits AS
(
    SELECT
        capture_date,
        wait_type,
        total_wait_ms,
        RANK() OVER (PARTITION BY capture_date ORDER BY total_wait_ms DESC) AS rn,
        SUM(total_wait_ms) OVER (PARTITION BY capture_date)                AS day_total_ms
    FROM DailyTotals
)
SELECT
    capture_date,
    rn,
    wait_type,
    total_wait_ms,
    CAST(100.0 * total_wait_ms / NULLIF(day_total_ms, 0) AS decimal(5,2)) AS pct_of_total
FROM RankedWaits
WHERE rn <= 5;
GO
