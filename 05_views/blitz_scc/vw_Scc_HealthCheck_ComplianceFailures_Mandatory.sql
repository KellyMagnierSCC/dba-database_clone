SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_Scc_HealthCheck_ComplianceFailures_Mandatory]
AS
SELECT
    r.ServerName,
    r.InstanceName,
    r.RunDateUTC,

    f.CheckID,
    f.Priority,
    f.FindingsGroup,
    f.Finding,
    f.DatabaseName,
    f.Details,
    f.URL,

    b.BaselineDomain,
    b.OwnerTeam,
    'FAIL' AS ComplianceState
FROM dbo.vw_HealthCheck_LatestFindings f
JOIN dbo.vw_HealthCheck_LatestRun r
    ON f.HealthCheckRunID = r.HealthCheckRunID
JOIN dbo.Scc_HealthCheck_BaselineRule b
    ON f.CheckID = b.CheckID
LEFT JOIN dbo.Scc_HealthCheck_AcceptedRisk ar
    ON ar.CheckID = f.CheckID
   AND (
        (ar.ScopeType = 'Instance' AND ar.ScopeName = '<INSTANCE>')
     OR (ar.ScopeType = 'Database' AND ar.ScopeName = f.DatabaseName)
    )
WHERE
    b.RequiredState = 'Mandatory'
    AND f.CheckID <> 4              -- Sysadmins excluded here
    AND ar.CheckID IS NULL;

GO
