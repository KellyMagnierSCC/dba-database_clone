SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Blocking_Tree_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Blocking_Tree_History](
	[BLOCKING_TREE] [nvarchar](max) NULL,
	[dd hh:mm:ss.mss] [varchar](8000) NULL,
	[wait_info] [nvarchar](4000) NULL,
	[blocked_session_count] [varchar](30) NULL,
	[blocking_session_id] [smallint] NULL,
	[login_name] [nvarchar](128) NULL,
	[host_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[locks] [xml] NULL,
	[tempdb_allocations] [varchar](30) NULL,
	[tempdb_current] [varchar](30) NULL,
	[reads] [varchar](30) NULL,
	[writes] [varchar](30) NULL,
	[physical_reads] [varchar](30) NULL,
	[CPU] [varchar](30) NULL,
	[used_memory] [varchar](30) NULL,
	[status] [varchar](30) NULL,
	[open_tran_count] [varchar](30) NULL,
	[percent_complete] [varchar](30) NULL,
	[start_time] [datetime] NULL,
	[login_time] [datetime] NULL,
	[request_id] [int] NULL,
	[sql_command] [xml] NULL,
	[collection_time] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO
