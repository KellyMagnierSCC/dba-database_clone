SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_Instance_LogUsage_Latest]
AS
-- Log usage per database from the most recent capture by usp_Monitor_CaptureLogUsage.
-- A database that has been dropped or taken offline drops out of this view at the next capture.
SELECT
    h.DatabaseName,
    h.RecoveryModel,
    h.TotalLogSizeMB,
    h.ActiveLogSizeMB,
    h.PercentActive,
    h.TotalVlfCount,
    h.ActiveVlfCount,
    h.LogTruncationHoldupReason,
    h.LastLogBackupTime,
    h.OldestOpenTranBeginTime,
    h.OldestOpenTranAgeSec,
    h.OldestOpenTranSessionID,
    h.CaptureDate
FROM dbo.LogUsage_History AS h
WHERE h.CaptureDate = (SELECT MAX(CaptureDate) FROM dbo.LogUsage_History);
GO
