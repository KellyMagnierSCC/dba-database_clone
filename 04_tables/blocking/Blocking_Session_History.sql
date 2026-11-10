SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Blocking_Session_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Blocking_Session_History](
	[collection_time] [datetime] NOT NULL,
	[start_time] [datetime] NOT NULL,
	[session_id] [smallint] NOT NULL,
	[sql_text] [xml] NULL,
	[query_plan] [xml] NULL,
	[wait_info] [nvarchar](4000) NULL,
	[blocking_session_id] [smallint] NULL,
	[blocked_session_count] [smallint] NULL,
	[additional_info] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO
