SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Activity_Session_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Activity_Session_History](
	[collection_time] [datetime] NOT NULL,
	[dd hh:mm:ss.mss] [varchar](8000) NULL,
	[login_time] [datetime] NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[session_id] [smallint] NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[blocking_session_id] [smallint] NULL,
	[blocked_session_count] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[open_tran_count] [varchar](30) NULL,
	[tran_start_time] [datetime] NULL,
	[tran_log_writes] [nvarchar](4000) NULL,
	[host_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[start_time] [datetime] NOT NULL,
	[sql_text] [xml] NULL,
	[sql_command] [xml] NULL,
	[query_plan] [xml] NULL,
	[reads] [varchar](50) NULL,
	[physical_reads] [varchar](50) NULL,
	[used_memory] [varchar](50) NULL,
	[CPU] [varchar](50) NULL,
	[tempdb_allocations] [varchar](50) NULL,
	[tempdb_current] [varchar](50) NULL,
	[additional_info] [xml] NULL,
	-- set by usp_Monitor_CaptureActivity, not by sp_WhoIsActive
	[CaptureReason] [varchar](30) NULL,
	[CaptureDBName] [sysname] NULL,
	[CaptureDetail] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO
