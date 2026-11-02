-- ============================================================================
-- local_deploy.example.sql - personal SSMS deployment wrapper.
--
-- 1. Copy this file to 09_deployment\local_deploy.sql. That name is in .gitignore, so your
--    values never get committed.
-- 2. Set the values below for the server you are deploying to.
-- 3. Uncomment the ONE deploy script you want to run.
-- 4. Open it in SSMS, connect to the target server, turn on Query > SQLCMD Mode, and run it.
--
-- The generated deploy scripts do not set these variables themselves, so they come from here.
-- RepoRoot must be a full path without spaces.
-- ============================================================================
:setvar RepoRoot "D:\DevOps\dba-database"
:setvar DatabaseName "DBA"

-- Only deploy_all.sql needs these (used when it has to create the database):
:setvar DataPath "E:\MOUNT\Databases\Data\Data01"
:setvar LogPath "E:\MOUNT\Databases\Logs\Log01"

-- :r $(RepoRoot)\09_deployment\deploy_all.sql
-- :r $(RepoRoot)\09_deployment\deploy_third_party.sql
-- :r $(RepoRoot)\09_deployment\packages\deploy_scc_cpu.sql
