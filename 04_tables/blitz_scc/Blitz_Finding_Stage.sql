SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Blitz_Finding_Stage]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Blitz_Finding_Stage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[Priority] [tinyint] NULL,
	[FindingsGroup] [varchar](50) NULL,
	[Finding] [varchar](200) NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[URL] [varchar](200) NULL,
	[Details] [nvarchar](4000) NULL,
	[QueryPlan] [xml] NULL,
	[QueryPlanFiltered] [nvarchar](max) NULL,
	[CheckID] [int] NULL,
 CONSTRAINT [PK_0410D3FA-BA11-46AF-A506-534DEA8CD5D7] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO
