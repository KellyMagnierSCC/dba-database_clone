SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- The 5 biggest waits per 4-hour bucket (00:00-03:59, 04:00-07:59, ...), by total wait time,
-- with each one's share of the bucket's total.
-- Reads vw_WaitStats_Delta, which removes benign waits and handles counter resets: after a
-- restart, the waits counted since the restart are included instead of the interval being lost.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_Top5WaitsPerBucket]
AS
WITH BucketTotals AS
(
    SELECT
        CAST(capture_time AS date)        AS capture_date,
        DATEPART(HOUR, capture_time) / 4  AS bucket_num,
        CONVERT(varchar(2), DATEPART(HOUR, capture_time) / 4 * 4) + ':00 - '
          + CONVERT(varchar(2), DATEPART(HOUR, capture_time) / 4 * 4 + 3) + ':59' AS hour_range,
        wait_type,
        SUM(delta_wait_time_ms)           AS total_wait_ms
    FROM dbo.vw_WaitStats_Delta
    WHERE delta_wait_time_ms > 0
    GROUP BY
        CAST(capture_time AS date),
        DATEPART(HOUR, capture_time) / 4,
        CONVERT(varchar(2), DATEPART(HOUR, capture_time) / 4 * 4) + ':00 - '
          + CONVERT(varchar(2), DATEPART(HOUR, capture_time) / 4 * 4 + 3) + ':59',
        wait_type
),
RankedWaits AS
(
    SELECT
        capture_date,
        bucket_num,
        hour_range,
        wait_type,
        total_wait_ms,
        RANK() OVER (PARTITION BY capture_date, hour_range ORDER BY total_wait_ms DESC) AS rn,
        SUM(total_wait_ms) OVER (PARTITION BY capture_date, hour_range)                AS day_total_ms
    FROM BucketTotals
)
SELECT
    capture_date,
    bucket_num,
    hour_range,
    rn,
    wait_type,
    total_wait_ms,
    CAST(100.0 * total_wait_ms / NULLIF(day_total_ms, 0) AS decimal(5,2)) AS pct_of_total
FROM RankedWaits
WHERE rn <= 5;
GO
