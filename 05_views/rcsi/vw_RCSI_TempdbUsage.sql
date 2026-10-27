SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_RCSI_TempdbUsage]
AS
SELECT
    SUM(user_object_reserved_page_count) * 8 / 1024.0 AS mb_user_objects,
    SUM(internal_object_reserved_page_count) * 8 / 1024.0 AS mb_internal,
    SUM(version_store_reserved_page_count) * 8 / 1024.0 AS mb_version_store,
    SUM(unallocated_extent_page_count) * 8 / 1024.0 AS mb_free
FROM tempdb.sys.dm_db_file_space_usage;
GO
