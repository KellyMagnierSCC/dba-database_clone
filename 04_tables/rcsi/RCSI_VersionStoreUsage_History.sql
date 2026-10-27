SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[RCSI_VersionStoreUsage_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[RCSI_VersionStoreUsage_History](
	[capture_time] [datetime2](7) NOT NULL,
	[database_name] [sysname] NOT NULL,
	[version_store_mb] [decimal](18, 2) NULL
) ON [PRIMARY];
ALTER TABLE [dbo].[RCSI_VersionStoreUsage_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
