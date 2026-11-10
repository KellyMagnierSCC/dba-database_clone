SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Scc_HealthCheck_BaselineRule]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Scc_HealthCheck_BaselineRule](
	[CheckID] [int] NOT NULL,
	[BaselineDomain] [varchar](50) NOT NULL,
	[RequiredState] [varchar](20) NOT NULL,
	[AppliesTo] [varchar](20) NOT NULL,
	[OwnerTeam] [varchar](50) NOT NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_Scc_HealthCheck_BaselineRule] PRIMARY KEY CLUSTERED 
(
	[CheckID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
END
GO
