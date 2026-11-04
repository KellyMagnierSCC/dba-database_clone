SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- The 5 biggest waits per 5-minute bucket, by total wait time, with each one's share of the
-- bucket's total.
-- Reads vw_WaitStats_Delta, which removes benign waits and handles counter resets: after a
-- restart, the waits counted since the restart are included instead of the interval being lost.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_Top5WaitsPerBucket_5mins]
AS
WITH Buckets AS
(
    SELECT
        CAST(capture_time AS date) AS capture_date,

        -- 5-minute bucket number within the day (0-287)
        DATEDIFF
        (
            MINUTE,
            CAST(CAST(capture_time AS date) AS datetime),
            DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, capture_time) / 5) * 5, 0)
        ) / 5 AS bucket_num,

        -- Display range for the bucket
        CONVERT(varchar(5), DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, capture_time) / 5) * 5, 0), 108)
        + ' - ' +
        CONVERT(varchar(5), DATEADD(MINUTE, ((DATEDIFF(MINUTE, 0, capture_time) / 5) * 5) + 4, 0), 108) AS time_range,

        wait_type,
        delta_wait_time_ms
    FROM dbo.vw_WaitStats_Delta
    WHERE delta_wait_time_ms > 0
),
BucketTotals AS
(
    SELECT
        capture_date,
        bucket_num,
        time_range,
        wait_type,
        SUM(delta_wait_time_ms) AS total_wait_ms
    FROM Buckets
    GROUP BY
        capture_date,
        bucket_num,
        time_range,
        wait_type
),
RankedWaits AS
(
    SELECT
        capture_date,
        bucket_num,
        time_range,
        wait_type,
        total_wait_ms,
        RANK() OVER (PARTITION BY capture_date, bucket_num ORDER BY total_wait_ms DESC) AS rn,
        SUM(total_wait_ms) OVER (PARTITION BY capture_date, bucket_num)                AS bucket_total_ms
    FROM BucketTotals
)
SELECT
    capture_date,
    bucket_num,
    time_range,
    rn,
    wait_type,
    total_wait_ms,
    CAST(100.0 * total_wait_ms / NULLIF(bucket_total_ms, 0) AS decimal(5,2)) AS pct_of_total
FROM RankedWaits
WHERE rn <= 5;
GO
