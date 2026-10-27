SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WorkloadMetricsTestWaitStats]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WorkloadMetricsTestWaitStats](
	[wait_stat_id] [bigint] IDENTITY(1,1) NOT NULL,
	[run_id] [int] NOT NULL,
	[query_id] [int] NOT NULL,
	[wait_type] [nvarchar](60) NOT NULL,
	[waiting_tasks_delta] [bigint] NOT NULL,
	[wait_ms_delta] [bigint] NOT NULL,
	[max_wait_ms] [bigint] NOT NULL,
	[captured_at] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_WorkloadMetricsTestWaitStats] PRIMARY KEY CLUSTERED 
(
	[wait_stat_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[WorkloadMetricsTestWaitStats] ADD  DEFAULT (sysutcdatetime()) FOR [captured_at];
ALTER TABLE [dbo].[WorkloadMetricsTestWaitStats]  WITH CHECK ADD  CONSTRAINT [FK_WaitStats_Query] FOREIGN KEY([query_id])
REFERENCES [dbo].[WorkloadMetricsTestQueries] ([query_id]);
ALTER TABLE [dbo].[WorkloadMetricsTestWaitStats] CHECK CONSTRAINT [FK_WaitStats_Query];
ALTER TABLE [dbo].[WorkloadMetricsTestWaitStats]  WITH CHECK ADD  CONSTRAINT [FK_WaitStats_Run] FOREIGN KEY([run_id])
REFERENCES [dbo].[WorkloadMetricsTestRuns] ([run_id]);
ALTER TABLE [dbo].[WorkloadMetricsTestWaitStats] CHECK CONSTRAINT [FK_WaitStats_Run];
END
GO
