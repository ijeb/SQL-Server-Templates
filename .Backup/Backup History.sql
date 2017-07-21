/* -------------------------------------------------------------------------- 
   Database Backups history for previous week including time it took to run
-------------------------------------------------------------------------  */

SELECT  CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [server] ,
        msdb.dbo.backupset.database_name ,
        msdb.dbo.backupset.backup_start_date ,
        msdb.dbo.backupset.backup_finish_date ,
        DATEDIFF(mi, msdb.dbo.backupset.backup_start_date,
                 msdb.dbo.backupset.backup_finish_date) AS [backup_time_minutes] ,
        CASE msdb..backupset.[type]
          WHEN 'D' THEN 'Database'
          WHEN 'I' THEN 'Differential database'
          WHEN 'L' THEN 'Log'
          WHEN 'F' THEN 'File or filegroup'
          WHEN 'G' THEN 'Differential file'
          WHEN 'P' THEN 'Partial'
          WHEN 'Q' THEN 'Differential partial'
        END AS backup_type ,
        msdb.dbo.backupset.backup_size ,
        msdb.dbo.backupmediafamily.logical_device_name ,
        msdb.dbo.backupmediafamily.physical_device_name
FROM    msdb.dbo.backupmediafamily
        INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE   ( CONVERT(DATETIME, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7 )
AND database_name = N''
ORDER BY msdb.dbo.backupset.database_name ,
        msdb.dbo.backupset.backup_finish_date