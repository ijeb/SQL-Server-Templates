/*   

If you need to start SQL Server without tempdb you can do that with this:

NET START MSSQLSERVER /f /T3608  -- default instance
NET START MSSQL$instancename /f /T3608  -- named instance

If you need to identify current location and tempdb is available you can query

USE tempdb 
GO 

EXEC sp_helpfile 
GO

*/


USE master 
GO 

ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'new location') 
GO 

ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'new location') 
GO 

