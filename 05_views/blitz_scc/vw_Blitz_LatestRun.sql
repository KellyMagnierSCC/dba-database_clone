SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create Views
CREATE OR ALTER VIEW [dbo].[vw_Blitz_LatestRun]
AS
SELECT *
FROM dbo.Blitz_Run r
WHERE r.RunDateUTC = (
    SELECT MAX(RunDateUTC) FROM dbo.Blitz_Run
)

GO
