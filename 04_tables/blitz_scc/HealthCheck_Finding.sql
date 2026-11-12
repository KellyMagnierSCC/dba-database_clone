SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[HealthCheck_Finding]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[HealthCheck_Finding](
	[HealthCheckFindingID] [bigint] IDENTITY(1,1) NOT NULL,
	[HealthCheckRunID] [int] NOT NULL,
	-- CheckID, Priority, Finding, FindingsGroup, Details, DatabaseName and URL are sp_Blitz's output.
	-- CheckID is sp_Blitz's check number: Scc_HealthCheck_BaselineRule and the compliance views key on it.
	[CheckID] [int] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[Finding] [nvarchar](400) NOT NULL,
	[FindingsGroup] [nvarchar](50) NULL,
	[Details] [nvarchar](max) NULL,
	[DatabaseName] [sysname] NULL,
	[URL] [nvarchar](4000) NULL,
	[CreateDateUTC] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_HealthCheck_Finding] PRIMARY KEY CLUSTERED 
(
	[HealthCheckFindingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
CREATE NONCLUSTERED INDEX [IX_HealthCheck_Finding_HealthCheckRunID_CheckID] ON [dbo].[HealthCheck_Finding]
(
	[HealthCheckRunID] ASC,
	[CheckID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
ALTER TABLE [dbo].[HealthCheck_Finding] ADD  CONSTRAINT [DF_HealthCheck_Finding_CreateDateUTC]  DEFAULT (sysutcdatetime()) FOR [CreateDateUTC];
ALTER TABLE [dbo].[HealthCheck_Finding]  WITH CHECK ADD  CONSTRAINT [FK_HealthCheck_Finding_HealthCheck_Run] FOREIGN KEY([HealthCheckRunID])
REFERENCES [dbo].[HealthCheck_Run] ([HealthCheckRunID]);
ALTER TABLE [dbo].[HealthCheck_Finding] CHECK CONSTRAINT [FK_HealthCheck_Finding_HealthCheck_Run];
END
GO
