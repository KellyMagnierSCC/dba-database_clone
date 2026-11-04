SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Can the trends be trusted? One row per hour, from the hour of the first capture up to the
-- current hour, including hours with no captures at all.
--
-- The expected interval is the capture job's schedule, 5 minutes (12 captures an hour). If the
-- schedule changes, change expected_interval_seconds in the Settings CTE below.
--
-- capture_status, in order of priority:
--   No captures       the job didn't run (or failed) for the whole hour
--   Missing captures  fewer captures than expected
--   Extra captures    more than expected: the job runs more often than the setting says
--   Counters reset    the wait counters were reset (restart or DBCC SQLPERF ... CLEAR)
--   OK
-- longest_gap_seconds belongs to the capture that ended the gap, so after an outage it shows
-- on the first hour with captures again.
-- capture_time is set by GETDATE() on the server, so this view uses GETDATE() too.
CREATE OR ALTER VIEW [dbo].[vw_WaitStats_CaptureHealth]
AS
WITH Settings AS
(
    SELECT 300 AS expected_interval_seconds
),
Bounds AS
(
    SELECT
        DATEADD(HOUR, DATEDIFF(HOUR, 0, MIN(capture_time)), 0) AS first_hour,
        MAX(capture_time)                                       AS last_capture_time
    FROM dbo.vw_WaitStats_Captures
),
Digits AS
(
    SELECT d FROM (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS v (d)
),
Hours AS
(
    -- Up to 100,000 hours (about 11 years) from the first capture to now
    SELECT DATEADD(HOUR, n.n, b.first_hour) AS capture_hour
    FROM Bounds AS b
    CROSS JOIN
    (
        SELECT d1.d + d2.d * 10 + d3.d * 100 + d4.d * 1000 + d5.d * 10000 AS n
        FROM Digits AS d1
        CROSS JOIN Digits AS d2
        CROSS JOIN Digits AS d3
        CROSS JOIN Digits AS d4
        CROSS JOIN Digits AS d5
    ) AS n
    WHERE n.n <= DATEDIFF(HOUR, b.first_hour, GETDATE())
),
HourCaptures AS
(
    SELECT
        DATEADD(HOUR, DATEDIFF(HOUR, 0, capture_time), 0) AS capture_hour,
        COUNT(*)                                          AS captures,
        MIN(capture_time)                                 AS first_capture_time,
        MAX(capture_time)                                 AS last_capture_time,
        MAX(interval_seconds)                             AS longest_gap_seconds,
        SUM(is_reset)                                     AS resets,
        MIN(wait_types_captured)                          AS min_wait_types_captured,
        MAX(wait_types_captured)                          AS max_wait_types_captured
    FROM dbo.vw_WaitStats_Captures
    GROUP BY DATEADD(HOUR, DATEDIFF(HOUR, 0, capture_time), 0)
),
Expected AS
(
    SELECT
        h.capture_hour,
        CASE WHEN h.capture_hour = DATEADD(HOUR, DATEDIFF(HOUR, 0, GETDATE()), 0) THEN 1 ELSE 0 END AS is_current_hour,
        -- The current hour only expects the captures due so far, counting the one at :00
        CASE WHEN h.capture_hour = DATEADD(HOUR, DATEDIFF(HOUR, 0, GETDATE()), 0)
             THEN DATEDIFF(SECOND, h.capture_hour, GETDATE()) / s.expected_interval_seconds + 1
             ELSE 3600 / s.expected_interval_seconds
        END AS expected_captures,
        s.expected_interval_seconds
    FROM Hours AS h
    CROSS JOIN Settings AS s
)
SELECT
    e.capture_hour,
    e.is_current_hour,
    e.expected_captures,
    ISNULL(c.captures, 0)                                                AS captures,
    CASE WHEN e.expected_captures - e.is_current_hour > ISNULL(c.captures, 0)
         THEN e.expected_captures - ISNULL(c.captures, 0) ELSE 0 END    AS missing_captures,
    c.longest_gap_seconds,
    ISNULL(c.resets, 0)                                                  AS resets,
    c.first_capture_time,
    c.last_capture_time,
    c.min_wait_types_captured,
    c.max_wait_types_captured,
    CASE
        WHEN ISNULL(c.captures, 0) = 0 AND e.expected_captures > 0 THEN 'No captures'
        -- In the current hour, the latest capture may still be running: allow one short
        WHEN ISNULL(c.captures, 0) < e.expected_captures - e.is_current_hour THEN 'Missing captures'
        WHEN c.captures > e.expected_captures + 1                  THEN 'Extra captures'
        WHEN c.resets > 0                                          THEN 'Counters reset'
        ELSE 'OK'
    END                                                                  AS capture_status,
    DATEDIFF(MINUTE, b.last_capture_time, GETDATE())                     AS minutes_since_last_capture
FROM Expected AS e
CROSS JOIN Bounds AS b
LEFT JOIN HourCaptures AS c
    ON c.capture_hour = e.capture_hour;
GO
