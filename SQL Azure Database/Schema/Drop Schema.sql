--==================================================================================
-- Drop Schema template for Azure SQL Database and Azure SQL Data Warehouse Database
--==================================================================================
IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'<sample_schema, sysname, sample_schema>'
)
DROP SCHEMA <sample_schema, sysname, sample_schema>
GO
