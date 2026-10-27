SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WorkloadMetricsTestQueries]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WorkloadMetricsTestQueries](
	[query_id] [int] IDENTITY(1,1) NOT NULL,
	[query_hash] [nvarchar](100) NOT NULL,
	[sample_query_text] [nvarchar](max) NOT NULL,
	[is_active] [bit] NOT NULL,
	[added_at] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_WorkloadMetricsTestQueries] PRIMARY KEY CLUSTERED 
(
	[query_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
ALTER TABLE [dbo].[WorkloadMetricsTestQueries] ADD  DEFAULT ((1)) FOR [is_active];
ALTER TABLE [dbo].[WorkloadMetricsTestQueries] ADD  DEFAULT (sysutcdatetime()) FOR [added_at];
END
GO
