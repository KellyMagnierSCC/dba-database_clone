SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[RCSI_ActiveTransactions_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[RCSI_ActiveTransactions_History](
	[capture_time] [datetime2](7) NOT NULL,
	[transaction_id] [bigint] NULL,
	[session_id] [int] NULL,
	[is_snapshot] [bit] NULL,
	[elapsed_time_seconds] [bigint] NULL,
	[login_name] [sysname] NOT NULL,
	[host_name] [sysname] NOT NULL,
	[program_name] [nvarchar](256) NULL,
	[status] [nvarchar](30) NULL,
	[database_name] [sysname] NULL
) ON [PRIMARY];
ALTER TABLE [dbo].[RCSI_ActiveTransactions_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
