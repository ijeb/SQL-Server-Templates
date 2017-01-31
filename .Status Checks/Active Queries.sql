SELECT  R.session_id ,
        CASE WHEN S.login_name = S.original_login_name THEN S.login_name
             ELSE S.login_name + ' (' + S.original_login_name + ')'
        END AS LOGIN_NAME ,
        DB_NAME(R.database_id) AS DATABASE_NAME ,
        R.command ,
        ST.text AS QUERY_TEXT ,
        QP.query_plan AS XML_QUERY_PLAN ,
        R.wait_type AS CURRENT_WAIT_TYPE ,
        R.last_wait_type ,
        R.blocking_session_id ,
        R.open_transaction_count ,
        R.percent_complete
FROM    sys.dm_exec_requests R
        LEFT OUTER JOIN sys.dm_exec_sessions S ON S.session_id = R.session_id
        LEFT OUTER JOIN sys.dm_exec_connections C ON C.connection_id = R.connection_id
        CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) ST
        CROSS APPLY sys.dm_exec_query_plan(R.plan_handle) QP
WHERE   R.status NOT IN ( 'BACKGROUND', 'SLEEPING' );
