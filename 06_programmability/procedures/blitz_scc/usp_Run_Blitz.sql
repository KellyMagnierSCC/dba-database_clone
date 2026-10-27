SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_Run_Blitz]
(
    @BringThePain bit = 1,
    @Notes        nvarchar(4000) = NULL,
    @OutputDB     nvarchar(80)   = 'DBA'  --Name of the Database the results are to be added to
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @BlitzRunID    int,
        @ServerName   sysname = @@SERVERNAME,
        @InstanceName sysname = ISNULL(CAST(SERVERPROPERTY('InstanceName') AS sysname),'MSSQLSERVER'),
        @SqlVersion   nvarchar(128) = CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)),
        @Login        sysname = ORIGINAL_LOGIN();

    BEGIN TRY

        -- Register run
        INSERT dbo.Blitz_Run
        (
            ServerName,
            InstanceName,
            SqlVersion,
            ExecutedBy,
            BringThePain,
            Notes
        )
        VALUES
        (
            @ServerName,
            @InstanceName,
            @SqlVersion,
            @Login,
            @BringThePain,
            @Notes
        );

        SET @BlitzRunID = SCOPE_IDENTITY();

        -- Clear staging
        TRUNCATE TABLE dbo.Blitz_Finding_Stage;

        -- Let sp_Blitz write directly
        EXEC dbo.sp_Blitz
            @CheckServerInfo = 1,
            @BringThePain = 1, --@BringThePain,
            @OutputType = 'TABLE',
            @OutputDatabaseName = @OutputDB,
            @OutputSchemaName = 'dbo',
            @OutputTableName = 'Blitz_Finding_Stage';

        -- Persist into history table
        INSERT dbo.Blitz_Finding
        (
            BlitzRunID,
            CheckID,
            Priority,
			FindingsGroup,
            Finding,
            DatabaseName,
            Details,
            URL
        )
        SELECT
            @BlitzRunID,
            CheckID,
            Priority,
			FindingsGroup,
            Finding,
            DatabaseName,
            Details,
            URL
        FROM dbo.Blitz_Finding_Stage;

    END TRY
    BEGIN CATCH
    DECLARE @ErrMsg nvarchar(4000) = ERROR_MESSAGE();

    RAISERROR (
        'usp_Run_Blitz failed: %s',
        16,   -- severity
        1,    -- state
        @ErrMsg
    );
END CATCH
END;
GO

