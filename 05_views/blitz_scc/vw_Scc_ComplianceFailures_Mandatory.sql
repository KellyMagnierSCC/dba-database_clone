SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_Scc_ComplianceFailures_Mandatory]
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
FROM dbo.vw_Blitz_LatestFindings f
JOIN dbo.vw_Blitz_LatestRun r
    ON f.BlitzRunID = r.BlitzRunID
JOIN dbo.Scc_BaselineRule b
    ON f.CheckID = b.CheckID
LEFT JOIN dbo.Scc_AcceptedRisk ar
    ON ar.CheckID = f.CheckID
   AND (
        (ar.ScopeType = 'Instance' AND ar.ScopeName = r.ServerName)   -- @@SERVERNAME recorded by usp_Run_Blitz
     OR (ar.ScopeType = 'Database' AND ar.ScopeName = f.DatabaseName)
    )
WHERE
    b.RequiredState = 'Mandatory'
    AND f.CheckID <> 4              -- Sysadmins excluded here
    AND ar.CheckID IS NULL;

GO
