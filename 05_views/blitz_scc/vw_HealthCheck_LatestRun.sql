SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_HealthCheck_LatestRun]
AS
SELECT
    r.HealthCheckRunID,
    r.ServerName,
    r.InstanceName,
    r.SqlVersion,
    r.RunDateUTC,
    r.ExecutedBy,
    r.CheckAllDatabases,
    r.Notes
FROM dbo.HealthCheck_Run r
WHERE r.RunDateUTC = (
    SELECT MAX(RunDateUTC) FROM dbo.HealthCheck_Run
)

GO
