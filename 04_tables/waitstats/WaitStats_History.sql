SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WaitStats_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WaitStats_History](
	[capture_time] [datetime2](7) NOT NULL,
	[wait_type] [nvarchar](120) NOT NULL,
	[waiting_tasks_count] [bigint] NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[max_wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL
) ON [PRIMARY];
ALTER TABLE [dbo].[WaitStats_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
