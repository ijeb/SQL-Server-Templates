-- ===========================
-- Backup Database Template
-- ===========================
BACKUP DATABASE <Database_Name, sysname, Database_Name> 
	TO  DISK = N'<Backup_Path,,C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\><Database_Name, sysname, Database_Name>.bak' 
WITH 
	NOFORMAT, 
	COMPRESSION,
	NOINIT,  
	NAME = N'<Database_Name, sysname, Database_Name>-Full Database Backup', 
	SKIP, 
	STATS = 10;
GO
