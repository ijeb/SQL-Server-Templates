
-- This script will print all orphaned user to result set
-- Drop scripts if needed are printed to the message box

SET NOCOUNT ON;

CREATE TABLE #orphaned_users ( db sysname, usr sysname );

/* FIND ALL ORPHANED USERS IN DATABASES */

EXEC sp_MSforeachdb 'INSERT INTO #orphaned_users SELECT ''?'', [name] from [?].sys.database_principals WHERE [name] not in (''guest'') and type in (''G'',''S'',''U'') and sid not in (SELECT sid FROM sys.server_principals)';

SELECT  *
FROM    #orphaned_users
ORDER BY db ,
        usr;

DECLARE @db VARCHAR(100);
DECLARE @usr VARCHAR(100);

DECLARE tmp CURSOR
FOR
    SELECT  db AS [Database] ,
            usr AS [User Name]
    FROM    #orphaned_users;

/* PRINT OUT DROP SCRIPTS TO MESSAGE SCREEN */

OPEN tmp;
FETCH NEXT FROM tmp INTO @db, @usr;
WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '/*-------------------------------------------------------------------------------------------------------------------------*/'
        PRINT '/*  DROP USER ' + @usr + '  */'
		PRINT 'USE [' + @db + '];';
		PRINT 'IF EXISTS (SELECT schema_name FROM information_schema.schemata WHERE SCHEMA_NAME = ''' + @usr + ''')'
		PRINT 'BEGIN'
		PRINT '    DROP SCHEMA [' + @usr + ']'
		PRINT 'END'
		PRINT 'GO'
		PRINT ''
        PRINT 'DROP USER [' + @usr + '];';
        PRINT 'GO';
        PRINT '/*-------------------------------------------------------------------------------------------------------------------------*/'
		PRINT ''
		PRINT ''
		PRINT ''
        FETCH NEXT FROM tmp INTO @db, @usr;    
    END;

CLOSE tmp;
DEALLOCATE tmp; 

DROP TABLE #orphaned_users;