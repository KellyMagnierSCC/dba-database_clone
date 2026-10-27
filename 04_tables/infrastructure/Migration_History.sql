SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- One row each time a deploy script runs a migration from 08_migrations (written by the generated
-- deploy scripts, not by the migrations). A migration that found nothing to do is still logged;
-- MIN(RunAt) per MigrationName is the first time it ran on this server.
IF OBJECT_ID(N'[dbo].[Migration_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Migration_History](
	[MigrationHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[MigrationName] [nvarchar](260) NOT NULL,
	[DeployScript] [nvarchar](128) NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[RunBy] [sysname] NOT NULL,
	[RunAt] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Migration_History] PRIMARY KEY CLUSTERED
(
	[MigrationHistoryID] ASC
)
) ON [PRIMARY];
ALTER TABLE [dbo].[Migration_History] ADD CONSTRAINT [DF_Migration_History_ServerName] DEFAULT (CONVERT(sysname, SERVERPROPERTY('ServerName'))) FOR [ServerName];
ALTER TABLE [dbo].[Migration_History] ADD CONSTRAINT [DF_Migration_History_RunBy] DEFAULT (SUSER_SNAME()) FOR [RunBy];
ALTER TABLE [dbo].[Migration_History] ADD CONSTRAINT [DF_Migration_History_RunAt] DEFAULT (sysutcdatetime()) FOR [RunAt];
CREATE NONCLUSTERED INDEX [IX_Migration_History_MigrationName] ON [dbo].[Migration_History] ([MigrationName], [RunAt]);
END
GO
