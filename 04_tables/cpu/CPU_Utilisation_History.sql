SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[CPU_Utilisation_History]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[CPU_Utilisation_History](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[SQLProcessCPU] [int] NOT NULL,
	[SystemIdleCPU] [int] NOT NULL,
	[OtherProcessCPU] [int] NOT NULL,
	[CaptureDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CPU_Utilisation_History] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
ALTER TABLE [dbo].[CPU_Utilisation_History] ADD  CONSTRAINT [DF_CPU_Utilisation_History_CaptureDate]  DEFAULT (sysutcdatetime()) FOR [CaptureDate];
END
GO
