-- ============================================================================
-- deploy_third_party.sql - vendor code only
-- ============================================================================
-- Deploys every third-party object (Adam Machanic, Ola Hallengren, Brent Ozar, Darling Data).
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

-- ola_hallengren
:r $(RepoRoot)\02_third_party\ola_hallengren\MaintenanceSolution.sql
-- brent_ozar
:r $(RepoRoot)\02_third_party\brent_ozar\Install-All-Scripts.sql
-- adam_machanic
:r $(RepoRoot)\02_third_party\adam_machanic\sp_WhoIsActive.sql
-- erik_darling
:r $(RepoRoot)\02_third_party\erik_darling\DarlingData.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
