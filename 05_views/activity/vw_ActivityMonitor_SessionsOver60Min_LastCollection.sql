SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[vw_ActivityMonitor_SessionsOver60Min_LastCollection] as
select collection_time, session_id, start_time, login_name,database_name,host_name,status FROM [dbo].[WhoIsActive_ActivityData]
  where collection_time = (select max(collection_time) from [dbo].[WhoIsActive_ActivityData])
  and datediff(mi,start_time,collection_time) >60
GO
