SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WorkloadMetricsTestIOStats]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WorkloadMetricsTestIOStats](
	[io_stat_id] [bigint] IDENTITY(1,1) NOT NULL,
	[run_id] [int] NOT NULL,
	[query_id] [int] NOT NULL,
	[file_id] [int] NOT NULL,
	[reads_delta] [bigint] NOT NULL,
	[bytes_read_delta] [bigint] NOT NULL,
	[io_stall_read_ms_delta] [bigint] NOT NULL,
	[writes_delta] [bigint] NOT NULL,
	[bytes_written_delta] [bigint] NOT NULL,
	[io_stall_write_ms_delta] [bigint] NOT NULL,
	[io_stall_total_ms_delta] [bigint] NOT NULL,
	[captured_at] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_WorkloadMetricsTestIOStats] PRIMARY KEY CLUSTERED 
(
	[io_stat_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[WorkloadMetricsTestIOStats] ADD  DEFAULT (sysutcdatetime()) FOR [captured_at];
ALTER TABLE [dbo].[WorkloadMetricsTestIOStats]  WITH CHECK ADD  CONSTRAINT [FK_IOStats_Query] FOREIGN KEY([query_id])
REFERENCES [dbo].[WorkloadMetricsTestQueries] ([query_id]);
ALTER TABLE [dbo].[WorkloadMetricsTestIOStats] CHECK CONSTRAINT [FK_IOStats_Query];
ALTER TABLE [dbo].[WorkloadMetricsTestIOStats]  WITH CHECK ADD  CONSTRAINT [FK_IOStats_Run] FOREIGN KEY([run_id])
REFERENCES [dbo].[WorkloadMetricsTestRuns] ([run_id]);
ALTER TABLE [dbo].[WorkloadMetricsTestIOStats] CHECK CONSTRAINT [FK_IOStats_Run];
END
GO
