SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- The cumulative wait counters from sys.dm_os_wait_stats, stored every 5 minutes by
-- usp_Monitor_CaptureWaitStats (wait types that have occurred, benign ones excluded).
-- Replaces WaitStats_History, a heap with no index: this table is clustered on
-- (capture_time, wait_type), so each capture is appended at the end and a purge by date removes
-- a block from the front. One capture is one capture_time, so the key is also unique: a capture
-- inserted twice is rejected.
IF OBJECT_ID(N'[dbo].[WaitStats_Capture_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WaitStats_Capture_History](
    [capture_time] [datetime2](7) NOT NULL,
    [wait_type] [nvarchar](120) NOT NULL,
    [waiting_tasks_count] [bigint] NOT NULL,
    [wait_time_ms] [bigint] NOT NULL,
    [max_wait_time_ms] [bigint] NOT NULL,
    [signal_wait_time_ms] [bigint] NOT NULL,
 CONSTRAINT [PK_WaitStats_Capture_History] PRIMARY KEY CLUSTERED ([capture_time] ASC, [wait_type] ASC)
) ON [PRIMARY];
ALTER TABLE [dbo].[WaitStats_Capture_History] ADD CONSTRAINT [DF_WaitStats_Capture_History_capture_time] DEFAULT (getdate()) FOR [capture_time];
END
GO
