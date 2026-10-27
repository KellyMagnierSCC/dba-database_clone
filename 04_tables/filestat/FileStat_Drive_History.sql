SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[FileStat_Drive_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[FileStat_Drive_History](
	[capture_time] [datetime] NOT NULL,
	[Drive] [char](2) NULL,
	[Volume Mount Point] [nvarchar](128) NULL,
	[Read Latency] [float] NULL,
	[Write Latency] [float] NULL,
	[Overall Latency] [float] NULL,
	[Avg Bytes/Read] [float] NULL,
	[Avg Bytes/Write] [float] NULL,
	[Avg Bytes/Transfer] [float] NULL
) ON [PRIMARY];
ALTER TABLE [dbo].[FileStat_Drive_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
