SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[vw_Admin_CommvaultLastBackups]
as
with RecentBackups as
(select database_name,
recovery_model,max(backup_start_date) Recent_BackupStart,max(backup_finish_date) Recent_BackupFinish
from msdb.dbo.backupset
where user_name = 'SURREYCC\SVC-Commvault-02'
group by database_name,
recovery_model)
select database_name, RECOVERY_MODEL, 
Recent_BackupFinish,DATEDIFF(MI, Recent_BackupFinish,getdate()) MI_BETWEEN_BACKUPS 
,case 
WHEN recovery_model = 'SIMPLE' AND DATEDIFF(MI, Recent_BackupFinish,getdate()) > 1440
THEN 'OUT OF RPO'
WHEN recovery_model = 'FULL' AND DATEDIFF(MI, Recent_BackupFinish,getdate()) > 90
THEN 'OUT OF RPO'
ELSE 'WITHIN RPO'
END as RPOMet
from RecentBackups
--order by 5
GO
