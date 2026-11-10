SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[Scc_HealthCheck_AcceptedRisk]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Scc_HealthCheck_AcceptedRisk](
	[CheckID] [int] NOT NULL,
	[ScopeType] [varchar](20) NOT NULL,
	[ScopeName] [sysname] NOT NULL,
	[ApprovedBy] [sysname] NOT NULL,
	[ApprovalDate] [date] NOT NULL,
	[ReviewByDate] [date] NOT NULL,
	[Justification] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_Scc_HealthCheck_AcceptedRisk] PRIMARY KEY CLUSTERED 
(
	[CheckID] ASC,
	[ScopeType] ASC,
	[ScopeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
END
GO
