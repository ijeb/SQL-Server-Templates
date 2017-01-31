--==========================================================================================
-- Drop External Table template for Azure SQL Database and Azure SQL Data Warehouse Database 
--==========================================================================================
IF EXISTS (
  SELECT *
	FROM sys.tables
	JOIN sys.schemas
	  ON sys.tables.schema_id = sys.schemas.schema_id
   WHERE sys.schemas.name = N'<schema_name, sysname, your_schema_name>'
     AND sys.tables.name = N'<table_name, sysname, your_external_table_name>'
)
DROP EXTERNAL TABLE <schema_name, sysname, your_schema_name>.<table_name, sysname, your_external_table_name>
GO