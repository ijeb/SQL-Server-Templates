--To update all jobs that do not have email notification enabled I run this:

DECLARE @jobid AS NVARCHAR(MAX)

DECLARE jobstep_cursor CURSOR FOR
 SELECT job_id 
 FROM msdb.dbo.sysjobs
 WHERE enabled = 1 AND notify_level_email = 0

OPEN jobstep_cursor;

FETCH NEXT FROM jobstep_cursor INTO @jobid;

WHILE @@FETCH_STATUS = 0
BEGIN 

EXEC msdb.dbo.sp_update_job @job_id = @jobid, 
 @notify_level_email=2, 
 @notify_level_netsend=2, 
 @notify_level_page=2, 
 @notify_email_operator_name=N'DBA' -- ! <-- change if needed


FETCH NEXT FROM jobstep_cursor INTO @jobid;

END

CLOSE jobstep_cursor
DEALLOCATE jobstep_cursor 