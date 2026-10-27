SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_Scc_ComplianceFailures_Sysadmin]
AS
SELECT
    r.ServerName,
    r.InstanceName,
    r.RunDateUTC,

    f.CheckID,
    f.Finding,
    -- Extract login name from Blitz description
    SUBSTRING(
        f.Details,
        CHARINDEX('[', f.Details) + 1,
        CHARINDEX(']', f.Details) - CHARINDEX('[', f.Details) - 1
    ) AS LoginName,

    'Security' AS BaselineDomain,
    'DBA' AS OwnerTeam,
    'FAIL' AS ComplianceState
FROM dbo.vw_Blitz_LatestFindings f
JOIN dbo.vw_Blitz_LatestRun r
    ON f.BlitzRunID = r.BlitzRunID
LEFT JOIN dbo.Scc_AcceptedRisk ar
    ON  ar.CheckID   = 4
    AND ar.ScopeName =
        SUBSTRING(
            f.Details,
            CHARINDEX('[', f.Details) + 1,
            CHARINDEX(']', f.Details) - CHARINDEX('[', f.Details) - 1
        )
WHERE
    f.CheckID = 4                    -- Sysadmins only
    AND ar.CheckID IS NULL;          -- NOT approved

GO
