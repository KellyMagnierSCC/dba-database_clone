SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WorkloadMetricsTestRuns]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WorkloadMetricsTestRuns](
	[run_id] [int] IDENTITY(1,1) NOT NULL,
	[run_label] [nvarchar](100) NOT NULL,
	[run_notes] [nvarchar](500) NULL,
	[run_started] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_WorkloadMetricsTestRuns] PRIMARY KEY CLUSTERED 
(
	[run_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[WorkloadMetricsTestRuns] ADD  DEFAULT (sysutcdatetime()) FOR [run_started];
END
GO
