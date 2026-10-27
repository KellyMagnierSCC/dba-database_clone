-- ============================================================================
-- deploy_scc_filestat_io.sql - SCC_Performance - File and IO Statistics
-- ============================================================================
-- File/drive IO statistics history capture and views.
--
-- Own objects: 14   Vendor objects: 0   Pulled from other packages: 0
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

:r $(RepoRoot)\04_tables\filestat\FileStat_Database_History.sql
:r $(RepoRoot)\04_tables\filestat\FileStat_Drive_History.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_Current.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_Delta.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_PctChange.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_RollingAvg.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Database_Spikes.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_Current.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_Delta.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_PctChange.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_RollingAvg.sql
:r $(RepoRoot)\05_views\filestat\vw_FileStat_Drive_Spikes.sql
:r $(RepoRoot)\05_views\io\vw_IO_UsageByDatabase.sql
:r $(RepoRoot)\06_programmability\procedures\filestat\usp_Monitor_CaptureFileStats.sql

:r $(RepoRoot)\10_metadata\apply_extended_properties.sql
