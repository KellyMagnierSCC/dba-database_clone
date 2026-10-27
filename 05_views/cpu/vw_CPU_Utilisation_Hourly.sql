SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE OR ALTER VIEW [dbo].[vw_CPU_Utilisation_Hourly]
AS
WITH Base AS
(
    SELECT
        EventTime,
        DATEFROMPARTS(
            YEAR(EventTime),
            MONTH(EventTime),
            DAY(EventTime)
        ) AS EventDate,
        DATEPART(HOUR, EventTime) AS EventHour,
        SQLProcessCPU,
        SystemIdleCPU,
        OtherProcessCPU
    FROM dbo.CPU_Utilisation_History   -- change to your table name
)
SELECT
    EventDate,
    EventHour,
    COUNT(*) AS Samples,
    AVG(SQLProcessCPU) AS Avg_SQLProcessCPU,
    AVG(SystemIdleCPU) AS Avg_SystemIdleCPU,
    AVG(OtherProcessCPU) AS Avg_OtherProcessCPU
FROM Base
GROUP BY EventDate, EventHour;
GO
