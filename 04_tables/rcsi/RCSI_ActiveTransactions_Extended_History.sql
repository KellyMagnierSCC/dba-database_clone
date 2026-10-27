SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[RCSI_ActiveTransactions_Extended_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[RCSI_ActiveTransactions_Extended_History](
	[capture_time] [datetime] NOT NULL,
	[transaction_id] [bigint] NULL,
	[session_id] [int] NULL,
	[is_snapshot] [bit] NULL,
	[elapsed_time_seconds] [bigint] NULL,
	[login_name] [nvarchar](128) NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[session_status] [nvarchar](30) NULL,
	[database_id] [int] NULL,
	[database_name] [nvarchar](128) NULL,
	[request_status] [nvarchar](30) NULL,
	[command] [nvarchar](128) NULL,
	[blocking_session_id] [int] NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_time] [int] NULL,
	[last_wait_type] [nvarchar](60) NULL,
	[cpu_time] [int] NULL,
	[total_elapsed_time] [int] NULL,
	[sql_text] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
ALTER TABLE [dbo].[RCSI_ActiveTransactions_Extended_History] ADD  DEFAULT (getdate()) FOR [capture_time];
END
GO
