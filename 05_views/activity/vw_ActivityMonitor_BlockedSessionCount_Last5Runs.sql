SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Cross-domain dependency: reads dbo.WhoIsActive_ActivityData (domain: activity)


CREATE OR ALTER   VIEW [dbo].[vw_ActivityMonitor_BlockedSessionCount_Last5Runs]
AS
--active  and blocked sessions per collection for last 5 runs
     select top 5 Collection_time,count(session_id) as active_sessions, sum(case when blocking_session_id is null then 0 else 1 end) as blocked_sessions
  FROM [dbo].[WhoIsActive_ActivityData]
    group by Collection_time
	order by collection_time desc

GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'IsThirdParty' , N'SCHEMA',N'dbo', N'VIEW',N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'IsThirdParty', @value=N'False' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs'
ELSE
BEGIN
	EXEC sys.sp_updateextendedproperty @name=N'IsThirdParty', @value=N'False' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs'
END
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'PackageName' , N'SCHEMA',N'dbo', N'VIEW',N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'PackageName', @value=N'SCC_WhoisActive - Activity and Blocking Monitoring' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs'
ELSE
BEGIN
	EXEC sys.sp_updateextendedproperty @name=N'PackageName', @value=N'SCC_WhoisActive - Activity and Blocking Monitoring' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs'
END
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'RepositoryGroup' , N'SCHEMA',N'dbo', N'VIEW',N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'RepositoryGroup', @value=N'activity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs'
ELSE
BEGIN
	EXEC sys.sp_updateextendedproperty @name=N'RepositoryGroup', @value=N'activity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ActivityMonitor_BlockedSessionCount_Last5Runs'
END
GO


