SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE OR ALTER VIEW [dbo].[vw_BlockingMonitor_BlockingTree_LastCollection]
as
SELECT TOP (1000) [BLOCKING_TREE]
      ,[dd hh:mm:ss.mss]
      ,[wait_info]
      ,[blocked_session_count]
      ,[blocking_session_id]
      ,[login_name]
      ,[host_name]
      ,[database_name]
      ,[program_name]
      ,[locks]
      ,[tempdb_allocations]
      ,[tempdb_current]
      ,[reads]
      ,[writes]
      ,[physical_reads]
      ,[CPU]
      ,[used_memory]
      ,[status]
      ,[open_tran_count]
      ,[percent_complete]
      ,[start_time]
      ,[login_time]
      ,[request_id]
      ,[sql_command]
      ,[collection_time]
  FROM [dbo].[WhoIsActive_BlockingTree]
  where collection_time = (select max(collection_time) from [WhoIsActive_BlockingTree])
  order by collection_time
GO
