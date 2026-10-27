SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[FileStat_Database_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[FileStat_Database_History](
	[capture_time] [datetime] NOT NULL,
	[Database Name] [sysname] NOT NULL,
	[avg_read_latency_ms] [numeric](10, 1) NULL,
	[avg_write_latency_ms] [numeric](10, 1) NULL,
	[avg_io_latency_ms] [numeric](10, 1) NULL,
	[File Size (MB)] [decimal](18, 2) NULL,
	[physical_name] [nvarchar](260) NULL,
	[type_desc] [nvarchar](60) NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL,
	[Resource Governor Total Read IO Latency (ms)] [bigint] NULL,
	[Resource Governor Total Write IO Latency (ms)] [bigint] NULL
) ON [PRIMARY];
ALTER TABLE [dbo].[FileStat_Database_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
