SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Blitz_Finding]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Blitz_Finding](
	[BlitzFindingID] [bigint] IDENTITY(1,1) NOT NULL,
	[BlitzRunID] [int] NOT NULL,
	[CheckID] [int] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[Finding] [nvarchar](400) NOT NULL,
	[FindingsGroup] [nvarchar](50) NULL,
	[Details] [nvarchar](max) NULL,
	[DatabaseName] [sysname] NULL,
	[URL] [nvarchar](4000) NULL,
	[CreateDateUTC] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_BlitzFinding] PRIMARY KEY CLUSTERED 
(
	[BlitzFindingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
CREATE NONCLUSTERED INDEX [IX_BlitzFinding_Run_Check] ON [dbo].[Blitz_Finding]
(
	[BlitzRunID] ASC,
	[CheckID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
ALTER TABLE [dbo].[Blitz_Finding] ADD  CONSTRAINT [DF_BlitzFinding_Date]  DEFAULT (sysutcdatetime()) FOR [CreateDateUTC];
ALTER TABLE [dbo].[Blitz_Finding]  WITH CHECK ADD  CONSTRAINT [FK_BlitzFinding_Run] FOREIGN KEY([BlitzRunID])
REFERENCES [dbo].[Blitz_Run] ([BlitzRunID]);
ALTER TABLE [dbo].[Blitz_Finding] CHECK CONSTRAINT [FK_BlitzFinding_Run];
END
GO
