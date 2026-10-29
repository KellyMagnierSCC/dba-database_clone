SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[LogGrowth_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[LogGrowth_History](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[LogicalFileName] [sysname] NOT NULL,
	[EventStartTime] [datetime] NOT NULL,      -- server local time, as recorded by the default trace
	[EventEndTime] [datetime] NULL,
	[DurationSec] [decimal](10, 3) NULL,
	[GrowthMB] [decimal](12, 2) NOT NULL,
	[CaptureDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_LogGrowth_History] PRIMARY KEY CLUSTERED
(
	[RecordID] ASC
)
) ON [PRIMARY];
ALTER TABLE [dbo].[LogGrowth_History] ADD CONSTRAINT [DF_LogGrowth_History_CaptureDate] DEFAULT (sysutcdatetime()) FOR [CaptureDate];
CREATE NONCLUSTERED INDEX [IX_LogGrowth_History_Event] ON [dbo].[LogGrowth_History] ([DatabaseName], [LogicalFileName], [EventStartTime]);
CREATE NONCLUSTERED INDEX [IX_LogGrowth_History_CaptureDate] ON [dbo].[LogGrowth_History] ([CaptureDate]);
END
GO
