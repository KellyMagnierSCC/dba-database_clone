SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Stores the current cumulative wait counters (vw_WaitStats_Current, benign waits excluded).
-- Called every 5 minutes by the capture job.
-- Wait types that have never occurred since the last restart (both counters 0) are not stored:
-- a missing row means "zero so far", and vw_WaitStats_Delta counts a wait type from zero when
-- it first appears.
CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureWaitStats]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.WaitStats_Capture_History (
        wait_type,
        waiting_tasks_count,
        wait_time_ms,
        max_wait_time_ms,
        signal_wait_time_ms
    )
    SELECT
        wait_type,
        waiting_tasks_count,
        wait_time_ms,
        max_wait_time_ms,
        signal_wait_time_ms
    FROM dbo.vw_WaitStats_Current
    WHERE waiting_tasks_count > 0
       OR wait_time_ms > 0;
END;
GO
