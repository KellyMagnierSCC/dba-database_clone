SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[RCSI_TempdbUsage_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[RCSI_TempdbUsage_History](
	[capture_time] [datetime2](7) NOT NULL,
	[mb_user_objects] [decimal](18, 2) NULL,
	[mb_internal] [decimal](18, 2) NULL,
	[mb_version_store] [decimal](18, 2) NULL,
	[mb_free] [decimal](18, 2) NULL
) ON [PRIMARY];
ALTER TABLE [dbo].[RCSI_TempdbUsage_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
