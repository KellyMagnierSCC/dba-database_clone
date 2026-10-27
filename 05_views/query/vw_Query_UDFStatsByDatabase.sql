SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_Query_UDFStatsByDatabase] as
-- Look at UDF execution statistics (UDF Stats by DB)
SELECT TOP (25) DB_NAME(database_id) AS [Database Name], 
		   OBJECT_NAME(object_id, database_id) AS [Function Name],
		   total_worker_time, execution_count, total_elapsed_time,  
           total_elapsed_time/execution_count AS [avg_elapsed_time],  
           last_elapsed_time, last_execution_time, cached_time, [type_desc] 
FROM sys.dm_exec_function_stats WITH (NOLOCK) 
ORDER BY total_worker_time DESC
GO
