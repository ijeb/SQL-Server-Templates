

DECLARE @user_name VARCHAR(100) = '<user_name, sysname, enter user name>';

DECLARE @sql VARCHAR(2048) ,
    @sort INT; 
DECLARE tmp CURSOR
FOR

/*********************************************/
/*********   DB CONTEXT STATEMENT    *********/
/*********************************************/
SELECT  '-- [-- DB CONTEXT --] --' AS [-- SQL STATEMENTS --] ,
        1 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  'USE' + SPACE(1) + QUOTENAME(DB_NAME()) AS [-- SQL STATEMENTS --] ,
        1 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  '' AS [-- SQL STATEMENTS --] ,
        2 AS [-- RESULT ORDER HOLDER --]
UNION


/*********************************************/
/*********    DB ROLE PERMISSIONS    *********/
/*********************************************/
SELECT  '-- [-- DB ROLES --] --' AS [-- SQL STATEMENTS --] ,
        3 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  'EXEC sp_addrolemember @rolename =' + SPACE(1)
        + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername ='
        + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''') AS [-- SQL STATEMENTS --] ,
        3 AS [-- RESULT ORDER HOLDER --]
FROM    sys.database_role_members AS rm
WHERE   USER_NAME(rm.member_principal_id) = @user_name
UNION
SELECT  '' AS [-- SQL STATEMENTS --] ,
        4 AS [-- RESULT ORDER HOLDER --]
UNION

/*********************************************/
/*********  OBJECT LEVEL PERMISSIONS *********/
/*********************************************/
SELECT  '-- [-- OBJECT LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --] ,
        5 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  CASE WHEN perm.state <> 'W' THEN perm.state_desc
             ELSE 'GRANT'
        END + SPACE(1) + perm.permission_name + SPACE(1) + 'ON '
        + QUOTENAME(SCHEMA_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name) 
        + CASE WHEN cl.column_id IS NULL THEN SPACE(0)
               ELSE '(' + QUOTENAME(cl.name) + ')'
          END + SPACE(1) + 'TO' + SPACE(1)
        + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE DATABASE_DEFAULT
        + CASE WHEN perm.state <> 'W' THEN SPACE(0)
               ELSE SPACE(1) + 'WITH GRANT OPTION'
          END AS [-- SQL STATEMENTS --] ,
        5 AS [-- RESULT ORDER HOLDER --]
FROM    sys.database_permissions AS perm
        INNER JOIN sys.objects AS obj ON perm.major_id = obj.[object_id]
        INNER JOIN sys.database_principals AS usr ON perm.grantee_principal_id = usr.principal_id
        LEFT JOIN sys.columns AS cl ON cl.column_id = perm.minor_id
                                       AND cl.[object_id] = perm.major_id
WHERE   usr.name = @user_name
UNION
SELECT  '' AS [-- SQL STATEMENTS --] ,
        6 AS [-- RESULT ORDER HOLDER --]
UNION

/*********************************************/
/*********    DB LEVEL PERMISSIONS   *********/
/*********************************************/
SELECT  '-- [--DB LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --] ,
        7 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  CASE WHEN perm.state <> 'W' THEN perm.state_desc
             ELSE 'GRANT'
        END + SPACE(1) + perm.permission_name --CONNECT, etc
        + SPACE(1) + 'TO' + SPACE(1) + '[' + USER_NAME(usr.principal_id) + ']' COLLATE DATABASE_DEFAULT 
        + CASE WHEN perm.state <> 'W' THEN SPACE(0)
               ELSE SPACE(1) + 'WITH GRANT OPTION'
          END AS [-- SQL STATEMENTS --] ,
        7 AS [-- RESULT ORDER HOLDER --]
FROM    sys.database_permissions AS perm
        INNER JOIN sys.database_principals AS usr ON perm.grantee_principal_id = usr.principal_id
WHERE   usr.name = @user_name
        AND [perm].[major_id] = 0
        AND [usr].[principal_id] > 4
        AND [usr].[type] IN ( 'G', 'S', 'U' )
UNION
SELECT  '' AS [-- SQL STATEMENTS --] ,
        8 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  '-- [--DB LEVEL SCHEMA PERMISSIONS --] --' AS [-- SQL STATEMENTS --] ,
        9 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  CASE WHEN perm.state <> 'W' THEN perm.state_desc
             ELSE 'GRANT'
        END + SPACE(1) + perm.permission_name + SPACE(1) + 'TO' + SPACE(1)
        + class_desc + '::' COLLATE DATABASE_DEFAULT
        + QUOTENAME(SCHEMA_NAME(grantee_principal_id))
        + CASE WHEN perm.state <> 'W' THEN SPACE(0)
               ELSE SPACE(1) + 'WITH GRANT OPTION'
          END AS [-- SQL STATEMENTS --] ,
        10 AS [-- RESULT ORDER HOLDER --]
FROM    sys.database_permissions AS perm
        INNER JOIN sys.schemas s ON perm.grantee_principal_id = s.schema_id
WHERE   class = 3
        AND SCHEMA_NAME(grantee_principal_id) = @user_name
ORDER BY [-- RESULT ORDER HOLDER --];


OPEN tmp;
FETCH NEXT FROM tmp INTO @sql, @sort;
WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @sql;
        FETCH NEXT FROM tmp INTO @sql, @sort;    
    END;

CLOSE tmp;
DEALLOCATE tmp; 
