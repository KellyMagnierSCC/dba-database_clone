SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_HealthCheck_LatestFindings]
AS
SELECT
    f.HealthCheckFindingID,
    f.HealthCheckRunID,
    f.CheckID,
    f.Priority,
    f.Finding,
    f.FindingsGroup,
    f.Details,
    f.DatabaseName,
    f.URL,
    f.CreateDateUTC
FROM dbo.HealthCheck_Finding f
JOIN dbo.vw_HealthCheck_LatestRun r
ON f.HealthCheckRunID = r.HealthCheckRunID

GO
