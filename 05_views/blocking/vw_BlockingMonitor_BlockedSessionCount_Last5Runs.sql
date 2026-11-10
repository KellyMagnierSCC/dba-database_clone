SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Cross-domain dependency: reads dbo.Activity_Session_History (domain: activity)


CREATE OR ALTER VIEW [dbo].[vw_BlockingMonitor_BlockedSessionCount_Last5Runs]
AS
--active  and blocked sessions per collection for last 5 runs
     select top 5 Collection_time,count(session_id) as active_sessions, sum(case when blocking_session_id is null then 0 else 1 end) as blocked_sessions
  FROM [dbo].[Activity_Session_History]
    group by Collection_time
	order by collection_time desc
GO
