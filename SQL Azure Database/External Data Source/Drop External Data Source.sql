-- ===============================================================================================
-- Drop external data source template for Azure SQL Database and Azure SQL Data Warehouse Database
-- ===============================================================================================

IF EXISTS (
  SELECT *
	FROM sys.external_data_sources	
   WHERE name = N'<data_source_name, sysname, your_data_source_name>'	 
)
DROP EXTERNAL DATA SOURCE <data_source_name, sysname, sample_data_source>
GO