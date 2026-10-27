-- ============================================================================
-- deploy_scc_cpu.sql - SCC_Performance - CPU Monitoring
-- ============================================================================
-- CPU utilisation history capture and views.
--
-- Own objects: 9   Vendor objects: 0   Pulled from other packages: 0
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

:r $(RepoRoot)\04_tables\cpu\CPU_Utilisation_History.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_HighUsage_Now.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_History_15minute_Interval.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_UsageByDatabase.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_TopSessions.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_UtilLast256Min.sql
:r $(RepoRoot)\05_views\cpu\vw_CPU_Utilisation_Hourly.sql
:r $(RepoRoot)\06_programmability\procedures\cpu\usp_Monitor_CaptureCpuUtilisation.sql
:r $(RepoRoot)\06_programmability\procedures\cpu\usp_Alert_HighCpu.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
