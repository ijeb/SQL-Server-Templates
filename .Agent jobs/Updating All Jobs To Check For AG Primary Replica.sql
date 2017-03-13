USE [msdb]
GO

CREATE TABLE #sysjobsteps(
	[job_id] [uniqueidentifier] NOT NULL,
	[step_id] [int] NOT NULL,
	[step_name] [sysname] NOT NULL,
	[subsystem] [nvarchar](40) NOT NULL,
	[command] [nvarchar](max) NULL,
	[flags] [int] NOT NULL,
	[additional_parameters] [nvarchar](max) NULL,
	[cmdexec_success_code] [int] NOT NULL,
	[on_success_action] [tinyint] NOT NULL,
	[on_success_step_id] [int] NOT NULL,
	[on_fail_action] [tinyint] NOT NULL,
	[on_fail_step_id] [int] NOT NULL,
	[server] [sysname] NULL,
	[database_name] [sysname] NULL,
	[database_user_name] [sysname] NULL,
	[retry_attempts] [int] NOT NULL,
	[retry_interval] [int] NOT NULL,
	[os_run_priority] [int] NOT NULL,
	[output_file_name] [nvarchar](200) NULL,
	[last_run_outcome] [int] NOT NULL,
	[last_run_duration] [int] NOT NULL,
	[last_run_retries] [int] NOT NULL,
	[last_run_date] [int] NOT NULL,
	[last_run_time] [int] NOT NULL,
	[proxy_id] [int] NULL,
	[step_uid] [uniqueidentifier] NULL
)

INSERT INTO #sysjobsteps
SELECT js.*
FROM msdb.dbo.sysjobsteps js
JOIN msdb.dbo.sysjobs j ON j.job_id = js.job_id
WHERE j.name IN ('NGW1 - Delete Old Messages','TNT_P_Test - DeleteSentEventAndOldThan12Hours')

DECLARE @job_id uniqueidentifier, @step_id int, @step_name sysname, @subsystem nvarchar(40), @command nvarchar(max) , @flags int, @additional_parameters nvarchar(max),
	@cmdexec_success_code int, @on_success_action tinyint, @on_success_step_id int, @on_fail_action tinyint, @on_fail_step_id int, @server sysname,  @database_name sysname,
	@database_user_name sysname, @retry_attempts int, @retry_interval int, @os_run_priority int, @output_file_name nvarchar(200), @last_run_outcome int, @last_run_duration int,
	@last_run_retries int, @last_run_date int, @last_run_time int, @proxy_id int, @step_uid uniqueidentifier

DECLARE jobs	CURSOR FOR SELECT DISTINCT job_id
				FROM msdb.dbo.sysjobs
				WHERE NOT EXISTS (	SELECT *
									FROM msdb.dbo.sysjobsteps
									WHERE sysjobsteps.step_name = 'Check Is AG Primary'
									AND sysjobs.job_id = sysjobsteps.job_id)

OPEN jobs

FETCH NEXT FROM jobs into @job_id

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @database_name = (SELECT database_name
	FROM (SELECT TOP (1) database_name, count(*) ct
			FROM #sysjobsteps
			WHERE job_id = @job_id
			GROUP BY database_name
			ORDER BY count(*) desc) a)

	IF @database_name IS NULL
	BEGIN
		GOTO SkipJob
	END

	IF @database_name NOT IN (SELECT database_name FROM sys.availability_databases_cluster)
	BEGIN
		GOTO SkipJob
	END

	SET @command = 'IF [master].sys.fn_hadr_is_primary_replica (''' + @database_name + ''') <> 1
	RAISERROR(''Not the PRIMARY server for this job, exiting with SUCCESS'' ,11,1)'

	DECLARE steps CURSOR FOR SELECT step_id
		FROM #sysjobsteps
		WHERE job_id = @job_id
		ORDER BY step_id DESC

	OPEN steps
	FETCH NEXT FROM steps into @step_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC msdb.dbo.sp_delete_jobstep @job_id=@job_id, @step_id=@step_id
		FETCH NEXT FROM steps into @step_id
	END
	CLOSE steps
	DEALLOCATE steps

	EXEC msdb.dbo.sp_add_jobstep @job_id=@job_id, @step_name='Check Is AG Primary',
			@step_id=1,
			@cmdexec_success_code=0,
			@on_success_action=3,
			@on_fail_action=1,
			@retry_attempts=0,
			@retry_interval=0,
			@os_run_priority=0, @subsystem='TSQL',
			@command=@command,
			@database_name='master',
			@flags=0

	DECLARE steps CURSOR FOR SELECT step_id+1, step_name, subsystem, command, flags, additional_parameters, cmdexec_success_code, on_success_action, on_success_step_id+1, on_fail_action, on_fail_step_id+1, server,
		database_name, database_user_name, retry_attempts, retry_interval, os_run_priority, output_file_name
		FROM #sysjobsteps
		WHERE job_id = @job_id
		ORDER BY step_id

	OPEN steps
	FETCH NEXT FROM steps INTO @step_id, @step_name, @subsystem, @command, @flags, @additional_parameters, @cmdexec_success_code, @on_success_action, @on_success_step_id, @on_fail_action, @on_fail_step_id, @server,
		@database_name, @databasE_user_name, @retry_attempts, @retry_interval, @os_run_priority, @output_file_name

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC msdb.dbo.sp_add_jobstep @job_id=@job_id, @step_name=@step_name,
			@step_id=@step_id,
			@cmdexec_success_code=@cmdexec_success_code,
			@on_success_action=@on_success_action,
			@on_fail_action=@on_fail_action,
			@on_success_step_id=@on_success_step_id,
			@on_fail_step_id=@on_fail_step_id,
			@retry_attempts=@retry_attempts,
			@retry_interval=@retry_interval,
			@os_run_priority=@os_run_priority, @subsystem=@subsystem,
			@command=@command,
			@database_name=@database_name,
			@flags=@flags
		FETCH NEXT FROM steps into @step_id, @step_name, @subsystem, @command, @flags, @additional_parameters, @cmdexec_success_code, @on_success_action, @on_success_step_id, @on_fail_action, @on_fail_step_id, @server,
			@database_name, @databasE_user_name, @retry_attempts, @retry_interval, @os_run_priority, @output_file_name
	END

	CLOSE steps
	DEALLOCATE steps

	EXEC msdb.dbo.sp_update_job @job_id = @job_id, @start_step_id = 1

	SkipJob:
	FETCH NEXT FROM jobs into @job_id

END

CLOSE jobs
DEALLOCATE jobs

DROP TABLE #sysjobsteps