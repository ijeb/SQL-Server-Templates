-- =============================
-- Backup Filegroups Template
-- =============================
USE master
GO

BACKUP DATABASE <Database_Name, sysname, Database_Name>
   FILE = N'<Logical_File_Name_1,sysname,Logical_File_Name_1>',
   FILEGROUP = N'PRIMARY',
   FILE = N'<Logical_File_Name_2, sysname, Logical_File_Name_2>', 
   FILEGROUP = N'<Filegroup_1, sysname, Filegroup_1>'
   TO <Backup_Device_Name, sysname, Backup_Device_Name>
GO
 