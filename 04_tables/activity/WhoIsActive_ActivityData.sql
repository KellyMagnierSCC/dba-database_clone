SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[WhoIsActive_ActivityData]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[WhoIsActive_ActivityData](
	[collection_time] [datetime] NOT NULL,
	[dd hh:mm:ss.mss] [varchar](8000) NULL,
	[login_time] [datetime] NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[session_id] [smallint] NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[blocking_session_id] [smallint] NULL,
	[status] [varchar](30) NOT NULL,
	[open_tran_count] [varchar](30) NULL,
	[host_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[start_time] [datetime] NOT NULL,
	[sql_text] [xml] NULL,
	[reads] [varchar](50) NULL,
	[writes] [varchar](50) NULL,
	[physical_reads] [varchar](50) NULL,
	[used_memory] [varchar](50) NULL,
	[CPU] [varchar](50) NULL,
	[tempdb_allocation] [varchar](50) NULL,
	[tempdb_current] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO
