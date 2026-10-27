SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Blitz_Run]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Blitz_Run](
	[BlitzRunID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[InstanceName] [sysname] NOT NULL,
	[SqlVersion] [nvarchar](128) NOT NULL,
	[RunDateUTC] [datetime2](0) NOT NULL,
	[ExecutedBy] [sysname] NOT NULL,
	[BringThePain] [bit] NOT NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_BlitzRun] PRIMARY KEY CLUSTERED 
(
	[BlitzRunID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[Blitz_Run] ADD  CONSTRAINT [DF_BlitzRun_RunDate]  DEFAULT (sysutcdatetime()) FOR [RunDateUTC];
END
GO
