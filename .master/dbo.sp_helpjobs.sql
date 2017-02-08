CREATE PROCEDURE [dbo].[sp_helpjobs]
	@Category varchar(100) = NULL,
	@Name varchar(100) = NULL,
	@OnlyEnabled bit = 1,
	@ShowHistory bit = 0,
	@ShowSteps bit = 0,
	@OnlyRunning bit = 0,
	@MinRuntimeMin tinyint = NULL
AS
SET NOCOUNT ON;
SELECT @@servername as instancename
	,j.job_id 
	,j.name
	,CAST(ISNULL(j.[enabled],0) AS bit) job_enabled
	,CAST(ISNULL(s.[enabled],0) AS bit) schedule_enabled
	,c.name category
	,j.description
	,ISNULL(CAST(s.active_start_time / 10000 AS VARCHAR(10)) + ':' + RIGHT('00' + CAST(s.active_start_time % 10000 / 100 AS VARCHAR(10)), 2),'') AS active_start_time
	,ISNULL(js.next_run_date,0) AS next_run_date
	,ISNULL(js.next_run_time,'') AS next_run_time
	,ISNULL(s.name, '') AS schedule_name
	,ISNULL(dbo.udf_schedule_description(s.freq_type, 
		s.freq_interval,  
		s.freq_subday_type, 
		s.freq_subday_interval, 
		s.freq_relative_interval,  
		s.freq_recurrence_factor, 
		s.active_start_date, 
		s.active_end_date,  
		s.active_start_time, 
		s.active_end_time),'No schedule') AS schedule_desc
	,Status = CASE WHEN (start_execution_date is not null AND stop_execution_date is null) THEN 'RUNNING' ELSE 'idle' END
	,CASE h.run_status
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Cancelled'
		WHEN 4 THEN 'In Progress'
		ELSE ''
     END AS execution_status
	, ISNULL(CAST(STR(h.run_date, 8, 0) AS DATETIME)
        + CAST(STUFF(STUFF(RIGHT('000000' + CAST (h.run_time AS VARCHAR(6)), 6),
                           5, 0, ':'), 3, 0, ':') AS DATETIME), '19000101') AS start_datetime
	, ISNULL(DATEADD(SECOND,
                ( ( h.run_duration / 1000000 ) * 86400 )
                + ( ( ( h.run_duration - ( ( h.run_duration / 1000000 )
                                           * 1000000 ) ) / 10000 ) * 3600 )
                + ( ( ( h.run_duration - ( ( h.run_duration / 10000 ) * 10000 ) )
                      / 100 ) * 60 ) + ( h.run_duration - ( h.run_duration
                                                            / 100 ) * 100 ),
                CAST(STR(h.run_date, 8, 0) AS DATETIME)
                + CAST(STUFF(STUFF(RIGHT('000000'
                                         + CAST (h.run_time AS VARCHAR(6)), 6),
                                   5, 0, ':'), 3, 0, ':') AS DATETIME)), '19000101') AS end_datetime
	, ISNULL(STUFF(STUFF(REPLACE(STR(h.run_duration, 6, 0), ' ', '0'), 3, 0, ':'), 6,
              0, ':'), '') AS duration_formatted
	, ISNULL(( ( ( h.run_duration / 1000000 ) * 86400 ) + ( ( ( h.run_duration
                                                         - ( ( h.run_duration
                                                              / 1000000 )
                                                             * 1000000 ) )
                                                       / 10000 ) * 3600 )
        + ( ( ( h.run_duration - ( ( h.run_duration / 10000 ) * 10000 ) )
              / 100 ) * 60 ) + ( h.run_duration - ( h.run_duration / 100 )
                                 * 100 ) ) / 60, 0) AS duration_min
	,j.date_created
	,j.date_modified
	,j.version_number
	,jp.name AS [job_owner]
	,ISNULL(sp.name, '') AS [schedule_owner]
	,st.step_id
	,st.step_name
	,st.subsystem
	,st.database_name
	,LEFT(st.command, 1000) command
	,st.output_file_name
FROM msdb.dbo.sysjobs j
LEFT OUTER JOIN msdb.dbo.syscategories c ON c.category_id = j.category_id
LEFT OUTER JOIN msdb.dbo.sysjobschedules js ON js.job_id = j.job_id
LEFT OUTER JOIN msdb.dbo.sysschedules s ON s.schedule_id = js.schedule_id
LEFT OUTER JOIN (SELECT job_id,step_id,step_name,subsystem,database_name,command,output_file_name FROM msdb.dbo.sysjobsteps
				 UNION ALL
				 SELECT job_id,0,NULL,NULL,NULL,NULL,NULL
				 FROM msdb.dbo.sysjobsteps
				 GROUP BY job_id
				) st ON st.job_id = j.job_id
LEFT OUTER JOIN (	SELECT job_id, step_id, max(instance_id) max_instance_id
					FROM msdb.dbo.sysjobhistory					
					GROUP BY job_id, step_id ) hmax ON hmax.job_id = j.job_id AND hmax.step_id = st.step_id
LEFT OUTER JOIN msdb.dbo.sysjobhistory h ON h.job_id = j.job_id AND h.step_id = st.step_id AND (@ShowHistory = 1 OR h.instance_id = hmax.max_instance_id)
CROSS JOIN (SELECT TOP 1 * FROM msdb.dbo.syssessions ORDER BY session_id DESC) se
LEFT OUTER JOIN msdb.dbo.sysjobactivity ja ON ja.job_id = j.job_id AND ja.session_id = se.session_id
LEFT OUTER JOIN sys.server_principals jp ON jp.sid = j.owner_sid
LEFT OUTER JOIN sys.server_principals sp ON sp.sid = s.owner_sid
WHERE (c.name = @Category OR @Category IS NULL)
AND (j.name = @Name OR @Name IS NULL)
AND (@OnlyEnabled = 0 OR j.[enabled] = 1)
AND (@ShowSteps = 1 OR st.step_id = 0)
AND (@OnlyRunning = 0 OR (start_execution_date is not null AND stop_execution_date is null))
AND ( ( ( ( h.run_duration / 1000000 ) * 86400 ) + ( ( ( h.run_duration
                                                         - ( ( h.run_duration
                                                              / 1000000 )
                                                             * 1000000 ) )
                                                       / 10000 ) * 3600 )
        + ( ( ( h.run_duration - ( ( h.run_duration / 10000 ) * 10000 ) )
              / 100 ) * 60 ) + ( h.run_duration - ( h.run_duration / 100 )
                                 * 100 ) ) / 60 > @MinRuntimeMin OR @MinRuntimeMin IS NULL)
