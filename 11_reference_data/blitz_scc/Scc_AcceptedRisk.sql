-- ============================================================================
-- Reference data: dbo.Scc_AcceptedRisk (standard rows only)
-- Accepted risks that apply on EVERY server, such as the logins approved for sysadmin.
-- Rows loaded from here have IsStandard = 1 and the repository owns them: each deployment
-- adds, changes and deletes them to match this list.
-- Server-specific accepted risks are NOT kept here. Add them on the server itself; they
-- have IsStandard = 0 (the default) and this script never changes or deletes them.
-- If a server already has a local row with the same key as a row below, the repository
-- takes it over (it is updated and IsStandard is set to 1).
-- To change a standard accepted risk, edit the VALUES list below and deploy. Re-runnable.
-- Read by: vw_Scc_ComplianceFailures_Mandatory, vw_Scc_ComplianceFailures_Sysadmin
-- ============================================================================
SET NOCOUNT ON;

DECLARE @Changes TABLE (Action nvarchar(10) NOT NULL);

MERGE [dbo].[Scc_AcceptedRisk] AS t
USING (VALUES
    -- CheckID, ScopeType, ScopeName, ApprovedBy, ApprovalDate, ReviewByDate,
    --     Justification
    (4, 'Login', N'SURREYCC\AG-SQL-Admin', N'Devops Team', '2026-03-10', '2027-03-10',
        N'Approved DBA administrative AD group'),
    (4, 'Login', N'SURREYCC\SVC-Commvault-02', N'Devops Team', '2026-03-10', '2026-09-10',
        N'Service Account for SQL Server backups required by commvault')
) AS s (CheckID, ScopeType, ScopeName, ApprovedBy, ApprovalDate, ReviewByDate, Justification)
    ON  t.CheckID   = s.CheckID
    AND t.ScopeType = s.ScopeType
    AND t.ScopeName = s.ScopeName
WHEN MATCHED AND (t.IsStandard = 0
                  OR EXISTS (SELECT s.ApprovedBy, CONVERT(date, s.ApprovalDate), CONVERT(date, s.ReviewByDate), s.Justification
                             EXCEPT
                             SELECT t.ApprovedBy, t.ApprovalDate, t.ReviewByDate, t.Justification))
    THEN UPDATE SET ApprovedBy    = s.ApprovedBy,
                    ApprovalDate  = s.ApprovalDate,
                    ReviewByDate  = s.ReviewByDate,
                    Justification = s.Justification,
                    IsStandard    = 1
WHEN NOT MATCHED BY TARGET
    THEN INSERT (CheckID, ScopeType, ScopeName, ApprovedBy, ApprovalDate, ReviewByDate, Justification, IsStandard)
         VALUES (s.CheckID, s.ScopeType, s.ScopeName, s.ApprovedBy, s.ApprovalDate, s.ReviewByDate, s.Justification, 1)
WHEN NOT MATCHED BY SOURCE AND t.IsStandard = 1   -- only rows this file owns; local rows are never deleted
    THEN DELETE
OUTPUT $action INTO @Changes (Action);

PRINT CONCAT(N'Scc_AcceptedRisk (standard rows): ',
             (SELECT COUNT(*) FROM @Changes WHERE Action = N'INSERT'), N' inserted, ',
             (SELECT COUNT(*) FROM @Changes WHERE Action = N'UPDATE'), N' updated, ',
             (SELECT COUNT(*) FROM @Changes WHERE Action = N'DELETE'), N' deleted.');
GO
