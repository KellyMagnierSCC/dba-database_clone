-- ============================================================================
-- deploy_scc_workloadmetrics.sql - SCC_Performance - Workload Metrics
-- ============================================================================
-- Workload test run/result tables and comparison view.
--
-- Own objects: 6   Vendor objects: 0   Pulled from other packages: 0
--
-- Settings are supplied when you deploy, not stored in the repo (see 09_deployment\config.sql).
-- sqlcmd:
--   sqlcmd -S <instance> -E -b -v RepoRoot="D:\DevOps\dba-database" DatabaseName="DBA" -i <this file>
-- SSMS (Query > SQLCMD Mode): run your own 09_deployment\local_deploy.sql
--   (copy local_deploy.example.sql; it is not committed).
-- RepoRoot must be a full path without spaces: the :r paths are unquoted because SSMS
-- does not expand variables inside a quoted path.
-- ============================================================================
:r $(RepoRoot)\09_deployment\config.sql
:on error exit
GO
USE [$(DatabaseName)]
GO

:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestQueries.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestRuns.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestDurations.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestIOStats.sql
:r $(RepoRoot)\04_tables\workload_metrics\WorkloadMetricsTestWaitStats.sql
:r $(RepoRoot)\05_views\workload_metrics\vw_WorkloadMetricsComparison.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
