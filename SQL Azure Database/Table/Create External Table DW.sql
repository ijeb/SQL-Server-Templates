-- ====================================================================
-- Create External Table template for Azure SQL Data Warehouse Database 
-- ====================================================================

IF OBJECT_ID('<schema_name, sysname, dbo>.<table_name, sysname, sample_externaltable>', 'U') IS NOT NULL
DROP EXTERNAL TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_externaltable>
GO

CREATE EXTERNAL TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_externaltable>
(
	<column1_name, sysname, c1> <column1_datatype, , int> <column1_nullability,, NOT NULL>, 
	<column2_name, sysname, c2> <column2_datatype, , char(10)> <column2_nullability,, NULL>, 
	<column3_name, sysname, c3> <column3_datatype, , datetime> <column3_nullability,, NULL>, 
)
WITH 
(
	LOCATION = N'<location, nvarchar(4000), sample_location>',
	DATA_SOURCE = <data_source_name, sysname, sample_data_source>,
	FILE_FORMAT = <file_format_name, sysname, sample_file_format>,
	REJECT_TYPE = <reject_type, nvarchar(20), sample_reject_type>,
	REJECT_VALUE = <reject_value, float, sample_reject_value>,
	REJECT_SAMPLE_VALUE = <reject_sample_value, float, sample_reject_sample_value>
)
GO