SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_RCSI_VersionStoreUsage]
AS
SELECT
    DB_NAME(database_id) AS database_name,
    reserved_page_count * 8 / 1024.0 AS version_store_mb
FROM sys.dm_tran_version_store_space_usage;
GO
