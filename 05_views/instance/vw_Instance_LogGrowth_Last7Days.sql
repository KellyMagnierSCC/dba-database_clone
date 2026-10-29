SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_Instance_LogGrowth_Last7Days]
AS
-- Log file autogrowth per database and log file over the last 7 days, from usp_Monitor_CaptureLogGrowth.
-- Frequent small growths usually mean the log's growth increment is too small.
SELECT
    g.DatabaseName,
    g.LogicalFileName,
    COUNT(*)           AS GrowthCount,
    SUM(g.GrowthMB)    AS TotalGrowthMB,
    SUM(g.DurationSec) AS TotalDurationSec,
    MAX(g.DurationSec) AS LongestGrowthSec,
    MAX(g.EventStartTime) AS LastGrowthTime   -- server local time
FROM dbo.LogGrowth_History AS g
WHERE g.EventStartTime >= DATEADD(DAY, -7, GETDATE())
GROUP BY
    g.DatabaseName,
    g.LogicalFileName;
GO
