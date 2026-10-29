SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[LogUsage_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[LogUsage_History](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[RecoveryModel] [nvarchar](60) NOT NULL,
	[TotalLogSizeMB] [decimal](18, 2) NOT NULL,
	[ActiveLogSizeMB] [decimal](18, 2) NOT NULL,
	[PercentActive] [decimal](5, 2) NOT NULL,
	[TotalVlfCount] [int] NOT NULL,
	[ActiveVlfCount] [int] NOT NULL,
	[LogTruncationHoldupReason] [nvarchar](60) NULL,
	[LastLogBackupTime] [datetime] NULL,
	[OldestOpenTranBeginTime] [datetime] NULL,      -- server local time
	[OldestOpenTranAgeSec] [int] NULL,
	[OldestOpenTranSessionID] [int] NULL,
	[CaptureDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_LogUsage_History] PRIMARY KEY CLUSTERED
(
	[RecordID] ASC
)
) ON [PRIMARY];
ALTER TABLE [dbo].[LogUsage_History] ADD CONSTRAINT [DF_LogUsage_History_CaptureDate] DEFAULT (sysutcdatetime()) FOR [CaptureDate];
CREATE NONCLUSTERED INDEX [IX_LogUsage_History_CaptureDate] ON [dbo].[LogUsage_History] ([CaptureDate]);
END
GO
