SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_Blitz_LatestFindings]
AS
SELECT f.*
FROM dbo.Blitz_Finding f
JOIN dbo.vw_Blitz_LatestRun r
ON f.BlitzRunID = r.BlitzRunID

GO
