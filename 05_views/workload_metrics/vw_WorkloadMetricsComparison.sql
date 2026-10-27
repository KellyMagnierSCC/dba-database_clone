SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- vw_WorkloadMetricsComparison.sql
-- Side-by-side comparison of baseline vs test run metrics
-- Deploy to: Monitoring database
-- ============================================================
-- Usage:
--   SELECT *
--   FROM dbo.vw_WorkloadMetricsComparison
--   WHERE baseline_run_label = 'BASELINE_01'
--     AND test_run_label     = 'TEST_01'
--   ORDER BY duration_ms_delta DESC;
-- ============================================================

CREATE OR ALTER VIEW [dbo].[vw_WorkloadMetricsComparison]
AS
WITH baseline AS (
    SELECT
        r.run_label,
        d.query_id,
        q.query_hash,
        AVG(d.duration_ms)          AS avg_duration_ms,
        AVG(d.logical_reads_delta)  AS avg_logical_reads,
        AVG(d.physical_reads_delta) AS avg_physical_reads,
        AVG(d.cpu_time_ms_delta)    AS avg_cpu_ms,
        AVG(d.tempdb_pages_delta)   AS avg_tempdb_pages,
        AVG(d.writes_delta)         AS avg_writes,
        AVG(d.concurrent_session_count) AS avg_concurrent_sessions
    FROM dbo.WorkloadMetricsTestDurations d
    JOIN dbo.WorkloadMetricsTestRuns    r ON r.run_id    = d.run_id
    JOIN dbo.WorkloadMetricsTestQueries q ON q.query_id  = d.query_id
    GROUP BY r.run_label, d.query_id, q.query_hash
),
test AS (
    SELECT
        r.run_label,
        d.query_id,
        q.query_hash,
        AVG(d.duration_ms)          AS avg_duration_ms,
        AVG(d.logical_reads_delta)  AS avg_logical_reads,
        AVG(d.physical_reads_delta) AS avg_physical_reads,
        AVG(d.cpu_time_ms_delta)    AS avg_cpu_ms,
        AVG(d.tempdb_pages_delta)   AS avg_tempdb_pages,
        AVG(d.writes_delta)         AS avg_writes,
        AVG(d.concurrent_session_count) AS avg_concurrent_sessions
    FROM dbo.WorkloadMetricsTestDurations d
    JOIN dbo.WorkloadMetricsTestRuns    r ON r.run_id    = d.run_id
    JOIN dbo.WorkloadMetricsTestQueries q ON q.query_id  = d.query_id
    GROUP BY r.run_label, d.query_id, q.query_hash
)
SELECT
    b.run_label                                             AS baseline_run_label,
    t.run_label                                             AS test_run_label,
    b.query_id,
    b.query_hash,

    -- Duration
    b.avg_duration_ms                                       AS baseline_duration_ms,
    t.avg_duration_ms                                       AS test_duration_ms,
    t.avg_duration_ms - b.avg_duration_ms                  AS duration_ms_delta,
    CASE WHEN b.avg_duration_ms > 0
         THEN CAST(ROUND(100.0 * (t.avg_duration_ms - b.avg_duration_ms) / b.avg_duration_ms, 1) AS DECIMAL(10,1))
         ELSE NULL END                                      AS duration_pct_change,

    -- Logical reads
    b.avg_logical_reads                                     AS baseline_logical_reads,
    t.avg_logical_reads                                     AS test_logical_reads,
    t.avg_logical_reads - b.avg_logical_reads              AS logical_reads_delta,

    -- Physical reads
    b.avg_physical_reads                                    AS baseline_physical_reads,
    t.avg_physical_reads                                    AS test_physical_reads,
    t.avg_physical_reads - b.avg_physical_reads            AS physical_reads_delta,

    -- CPU
    b.avg_cpu_ms                                            AS baseline_cpu_ms,
    t.avg_cpu_ms                                            AS test_cpu_ms,
    t.avg_cpu_ms - b.avg_cpu_ms                            AS cpu_ms_delta,

    -- TempDB
    b.avg_tempdb_pages                                      AS baseline_tempdb_pages,
    t.avg_tempdb_pages                                      AS test_tempdb_pages,
    t.avg_tempdb_pages - b.avg_tempdb_pages                AS tempdb_pages_delta,

    -- Writes
    b.avg_writes                                            AS baseline_writes,
    t.avg_writes                                            AS test_writes,
    t.avg_writes - b.avg_writes                            AS writes_delta,

    -- Concurrency context (for IO attribution confidence)
    b.avg_concurrent_sessions                               AS baseline_avg_concurrent_sessions,
    t.avg_concurrent_sessions                               AS test_avg_concurrent_sessions

FROM baseline b
JOIN test t ON t.query_id = b.query_id
           AND t.query_hash = b.query_hash;

GO
