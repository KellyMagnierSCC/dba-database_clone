SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureCpuUtilisation]
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src AS
    (
        SELECT 
            DATEADD(MINUTE, DATEDIFF(MINUTE, 0, [Event Time]), 0) AS EventTime,
            [SQL Server Process CPU Utilization] AS SQLProcessCPU,
            [System Idle Process] AS SystemIdleCPU,
            [Other Process CPU Utilization] AS OtherProcessCPU
        FROM dbo.vw_CPU_UtilLast256Min
    )
    INSERT INTO dbo.CPU_Utilisation_History (EventTime, SQLProcessCPU, SystemIdleCPU, OtherProcessCPU)
    SELECT 
        s.EventTime,
        s.SQLProcessCPU,
        s.SystemIdleCPU,
        s.OtherProcessCPU
    FROM src s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.CPU_Utilisation_History h
        WHERE h.EventTime = s.EventTime
    );
END
GO
