-- ============================================================================
-- deploy_scc_blitz.sql - SCC_Blitz - Health Check Framework
-- ============================================================================
-- Health check run/finding tables filled from sp_Blitz, usp_Monitor_CaptureHealthCheck and the compliance views.
--
-- Own objects: 10   Vendor objects: 1   Pulled from other packages: 0
-- Vendor objects: Install-All-Scripts
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

-- 02_third_party (1, from ThirdPartyRequires in packages.csv)
:r $(RepoRoot)\02_third_party\brent_ozar\Install-All-Scripts.sql

:r $(RepoRoot)\04_tables\blitz_scc\HealthCheck_Finding_Stage.sql
:r $(RepoRoot)\04_tables\blitz_scc\HealthCheck_Run.sql
:r $(RepoRoot)\04_tables\blitz_scc\HealthCheck_Finding.sql
:r $(RepoRoot)\04_tables\blitz_scc\Scc_HealthCheck_AcceptedRisk.sql
:r $(RepoRoot)\04_tables\blitz_scc\Scc_HealthCheck_BaselineRule.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_HealthCheck_LatestRun.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_HealthCheck_LatestFindings.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_Scc_HealthCheck_ComplianceFailures_Mandatory.sql
:r $(RepoRoot)\05_views\blitz_scc\vw_Scc_HealthCheck_ComplianceFailures_Sysadmin.sql
:r $(RepoRoot)\06_programmability\procedures\blitz_scc\usp_Monitor_CaptureHealthCheck.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
