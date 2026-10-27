SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE OR ALTER VIEW [dbo].[vw_CPU_History_15minute_Interval]
  as
  SELECT 
    -- Rounds the EventTime down to the nearest 15-minute interval
    DATEADD(minute, (DATEDIFF(minute, 0, EventTime) / 15) * 15, 0) AS IntervalStart,
    
    -- SQL Process CPU Stats
    MIN(SQLProcessCPU) AS MinSQLCPU,
    MAX(SQLProcessCPU) AS MaxSQLCPU,
    AVG(SQLProcessCPU) AS AvgSQLCPU,
    
    -- System Idle CPU Stats
    MIN(SystemIdleCPU) AS MinIdleCPU,
    MAX(SystemIdleCPU) AS MaxIdleCPU,
    AVG(SystemIdleCPU) AS AvgIdleCPU,
    
    -- Other Process CPU Stats
    MIN(OtherProcessCPU) AS MinOtherCPU,
    MAX(OtherProcessCPU) AS MaxOtherCPU,
    AVG(OtherProcessCPU) AS AvgOtherCPU
FROM [dbo].[CPU_Utilisation_History]
GROUP BY 
    DATEADD(minute, (DATEDIFF(minute, 0, EventTime) / 15) * 15, 0)

GO
