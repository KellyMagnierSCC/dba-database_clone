SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_Monitor_CaptureHealthCheck]
(
    @CheckAllDatabases bit = 1,   -- recorded in HealthCheck_Run; sp_Blitz's @BringThePain
    @Notes        nvarchar(4000) = NULL,
    @OutputDB     nvarchar(80)   = 'DBA'  --Name of the Database the results are to be added to
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @HealthCheckRunID int,
        @ServerName   sysname = @@SERVERNAME,
        @InstanceName sysname = ISNULL(CAST(SERVERPROPERTY('InstanceName') AS sysname),'MSSQLSERVER'),
        @SqlVersion   nvarchar(128) = CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)),
        @Login        sysname = ORIGINAL_LOGIN();

    BEGIN TRY

        -- Register run
        INSERT dbo.HealthCheck_Run
        (
            ServerName,
            InstanceName,
            SqlVersion,
            ExecutedBy,
            CheckAllDatabases,
            Notes
        )
        VALUES
        (
            @ServerName,
            @InstanceName,
            @SqlVersion,
            @Login,
            @CheckAllDatabases,
            @Notes
        );

        SET @HealthCheckRunID = SCOPE_IDENTITY();

        -- Clear staging
        TRUNCATE TABLE dbo.HealthCheck_Finding_Stage;

        -- Let sp_Blitz write directly
        EXEC dbo.sp_Blitz
            @CheckServerInfo = 1,
            @BringThePain = 1, --@CheckAllDatabases,
            @OutputType = 'TABLE',
            @OutputDatabaseName = @OutputDB,
            @OutputSchemaName = 'dbo',
            @OutputTableName = 'HealthCheck_Finding_Stage';

        -- Persist into history table
        INSERT dbo.HealthCheck_Finding
        (
            HealthCheckRunID,
            CheckID,
            Priority,
			FindingsGroup,
            Finding,
            DatabaseName,
            Details,
            URL
        )
        SELECT
            @HealthCheckRunID,
            CheckID,
            Priority,
			FindingsGroup,
            Finding,
            DatabaseName,
            Details,
            URL
        FROM dbo.HealthCheck_Finding_Stage;

    END TRY
    BEGIN CATCH
    DECLARE @ErrMsg nvarchar(4000) = ERROR_MESSAGE();

    RAISERROR (
        'usp_Monitor_CaptureHealthCheck failed: %s',
        16,   -- severity
        1,    -- state
        @ErrMsg
    );
END CATCH
END;
GO

