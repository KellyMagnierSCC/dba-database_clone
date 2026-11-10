SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  CREATE OR ALTER VIEW [dbo].[vw_ActivityMonitor_Sessions_LastCollection] as
  select [collection_time]
      ,[dd hh:mm:ss.mss]
      ,[login_time]
      ,[login_name]
      ,[session_id]
      ,[wait_info]
      ,[blocking_session_id]
      ,[status]
      ,[open_tran_count]
      ,[host_name]
      ,[database_name]
      ,[program_name]
      ,[start_time]
      ,cast([sql_text] as varchar(max)) as sql_text
 FROM [dbo].[Activity_Session_History]
  where collection_time = (select max(collection_time) from [dbo].[Activity_Session_History])
GO
