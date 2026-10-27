SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [dbo].[vw_Instance_LogFile_Usage]
as
--Details infomration about the size and usage of the log file per database
--can be used to replace DBCC SQLPERF(logspace) and is more configurable.
SELECT NAME  AS 'Database Name',
       log_backup_time  AS 'last log backup time',
       current_vlf_sequence_number,
       current_vlf_size_mb,
       total_vlf_count,
       active_vlf_count,
       total_log_size_mb,
       active_log_size_mb,
       Round(active_log_size_mb / total_log_size_mb * 100, 2) AS
       Percentage_in_Use,
       log_truncation_holdup_reason,
       log_recovery_size_mb,
       recovery_vlf_count,
       log_state
FROM   sys.databases AS s
       CROSS apply sys.Dm_db_log_stats(s.database_id) ls

GO
