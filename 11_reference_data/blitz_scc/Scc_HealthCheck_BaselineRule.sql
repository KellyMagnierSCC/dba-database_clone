-- ============================================================================
-- Reference data: dbo.Scc_HealthCheck_BaselineRule
-- The standard set of sp_Blitz checks the SCC compliance views report on. The same on every
-- server, and the repository is authoritative: each deployment makes the table match this list
-- exactly. Rows are added, changed AND deleted, so a rule removed here is removed everywhere.
-- To change a rule, edit the VALUES list below and deploy. Re-runnable.
-- Read by: vw_Scc_HealthCheck_ComplianceFailures_Mandatory
-- ============================================================================
SET NOCOUNT ON;

DECLARE @Changes TABLE (Action nvarchar(10) NOT NULL);

MERGE [dbo].[Scc_HealthCheck_BaselineRule] AS t
USING (VALUES
    -- CheckID, BaselineDomain, RequiredState, AppliesTo, OwnerTeam, Notes
    (1,   'Backups',         'Mandatory', 'Database',  'DBA',    N'Databases must have recent backups'),
    (2,   'Backups',         'Mandatory', 'Database',  'DBA',    N'Full recovery requires log backups'),
    (4,   'Security',        'Mandatory', 'Login',     'DBA',    N'Sysadmin role restricted to explicitly approved logins'),
    (25,  'Storage',         'Mandatory', 'Instance',  'Infra',  N'TempDB must not be on C drive'),
    (26,  'Storage',         'Mandatory', 'Instance',  'Infra',  N'User databases must not be on C drive'),
    (34,  'Integrity',       'Mandatory', 'Database',  'DBA',    N'Database corruption detected'),
    (51,  'InstanceSafety',  'Mandatory', 'Instance',  'DBA',    N'Memory dangerously low'),
    (68,  'Integrity',       'Mandatory', 'Database',  'DBA',    N'Last good CHECKDB over 2 weeks old'),
    (89,  'Integrity',       'Mandatory', 'Database',  'DBA',    N'Database corruption detected'),
    (90,  'Integrity',       'Mandatory', 'Database',  'DBA',    N'Database corruption detected'),
    (93,  'Backups',         'Mandatory', 'Database',  'DBA',    N'Backups must not be on same drive as data'),
    (119, 'Backups',         'Mandatory', 'Instance',  'DBA',    N'TDE certificate must be backed up'),
    (128, 'Reliability',     'Mandatory', 'Instance',  'DBA',    N'Unsupported SQL Server build'),
    (129, 'Reliability',     'Mandatory', 'Instance',  'DBA',    N'Dangerous SQL build (corruption)'),
    (157, 'Security',        'Mandatory', 'Instance',  'DBA',    N'Dangerous SQL build (security)'),
    (159, 'InstanceSafety',  'Mandatory', 'Instance',  'DBA',    N'Memory dangerously low in NUMA nodes'),
    (202, 'Backups',         'Mandatory', 'Instance',  'DBA',    N'Encryption certificate must be backed up recently'),
    (229, 'Licensing',       'Mandatory', 'Instance',  'DBA',    N'Evaluation edition not permitted'),
    (256, 'Backups',         'Mandatory', 'Database',  'DBA',    N'Log backups must not write to NUL'),
    (258, 'Security',        'Mandatory', 'Instance',  'DBA',    N'Dangerous service account'),
    (259, 'Security',        'Mandatory', 'Instance',  'DBA',    N'Dangerous service account'),
    (260, 'Security',        'Mandatory', 'Instance',  'DBA',    N'Dangerous service account'),
    (261, 'Security',        'Mandatory', 'Instance',  'DBA',    N'Dangerous service account'),
    (268, 'Availability',    'Mandatory', 'Instance',  'DBA',    N'AG replica falling behind')
) AS s (CheckID, BaselineDomain, RequiredState, AppliesTo, OwnerTeam, Notes)
    ON t.CheckID = s.CheckID
WHEN MATCHED AND EXISTS (SELECT s.BaselineDomain, s.RequiredState, s.AppliesTo, s.OwnerTeam, s.Notes
                         EXCEPT
                         SELECT t.BaselineDomain, t.RequiredState, t.AppliesTo, t.OwnerTeam, t.Notes)
    THEN UPDATE SET BaselineDomain = s.BaselineDomain,
                    RequiredState  = s.RequiredState,
                    AppliesTo      = s.AppliesTo,
                    OwnerTeam      = s.OwnerTeam,
                    Notes          = s.Notes
WHEN NOT MATCHED BY TARGET
    THEN INSERT (CheckID, BaselineDomain, RequiredState, AppliesTo, OwnerTeam, Notes)
         VALUES (s.CheckID, s.BaselineDomain, s.RequiredState, s.AppliesTo, s.OwnerTeam, s.Notes)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE
OUTPUT $action INTO @Changes (Action);

-- PRINT cannot contain a subquery, so the message is built with SELECT first
DECLARE @Msg nvarchar(400);
SELECT @Msg = CONCAT(N'Scc_HealthCheck_BaselineRule: ',
                     COUNT(CASE WHEN Action = N'INSERT' THEN 1 END), N' inserted, ',
                     COUNT(CASE WHEN Action = N'UPDATE' THEN 1 END), N' updated, ',
                     COUNT(CASE WHEN Action = N'DELETE' THEN 1 END), N' deleted.')
FROM @Changes;
PRINT @Msg;
GO
