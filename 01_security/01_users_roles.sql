-- Roles, users and service accounts. One statement block per principal; users are skipped if the server login is missing.

-- Role: SCOM_HealthService
IF DATABASE_PRINCIPAL_ID(N'SCOM_HealthService') IS NULL
    CREATE ROLE [SCOM_HealthService];
GO

-- User: NT SERVICE\HealthService
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'NT SERVICE\HealthService')
    PRINT N'Skipped user [NT SERVICE\HealthService]: server login does not exist on this instance.';
ELSE
BEGIN
    IF DATABASE_PRINCIPAL_ID(N'NT SERVICE\HealthService') IS NULL
        CREATE USER [NT SERVICE\HealthService] FOR LOGIN [NT SERVICE\HealthService] WITH DEFAULT_SCHEMA=[dbo];
    ALTER ROLE [SCOM_HealthService] ADD MEMBER [NT SERVICE\HealthService];
END
GO
