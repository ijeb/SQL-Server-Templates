-- ================================
-- Create Backup Device Template
-- ================================
USE master
GO

EXEC master.dbo.sp_addumpdevice  
	@devtype = N'disk', 
	@logicalname = N'<Backup_Device_Name, SYSNAME, Backup_Device_Name>', 
	@physicalname = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\<Backup_Device_Name, SYSNAME, Backup_Device_Name>.bak'
GO
