SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WorkloadMetricsTestDurations]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WorkloadMetricsTestDurations](
	[duration_id] [bigint] IDENTITY(1,1) NOT NULL,
	[run_id] [int] NOT NULL,
	[query_id] [int] NOT NULL,
	[execution_start] [datetime2](3) NOT NULL,
	[duration_ms] [int] NOT NULL,
	[rows_returned] [int] NOT NULL,
	[logical_reads_delta] [bigint] NULL,
	[physical_reads_delta] [bigint] NULL,
	[writes_delta] [bigint] NULL,
	[cpu_time_ms_delta] [bigint] NULL,
	[tempdb_pages_delta] [bigint] NULL,
	[concurrent_session_count] [int] NULL,
	[concurrent_total_reads] [bigint] NULL,
	[concurrent_total_writes] [bigint] NULL,
	[concurrent_logical_reads] [bigint] NULL,
 CONSTRAINT [PK_WorkloadMetricsTestDurations] PRIMARY KEY CLUSTERED 
(
	[duration_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[WorkloadMetricsTestDurations]  WITH CHECK ADD  CONSTRAINT [FK_Durations_Query] FOREIGN KEY([query_id])
REFERENCES [dbo].[WorkloadMetricsTestQueries] ([query_id]);
ALTER TABLE [dbo].[WorkloadMetricsTestDurations] CHECK CONSTRAINT [FK_Durations_Query];
ALTER TABLE [dbo].[WorkloadMetricsTestDurations]  WITH CHECK ADD  CONSTRAINT [FK_Durations_Run] FOREIGN KEY([run_id])
REFERENCES [dbo].[WorkloadMetricsTestRuns] ([run_id]);
ALTER TABLE [dbo].[WorkloadMetricsTestDurations] CHECK CONSTRAINT [FK_Durations_Run];
END
GO
