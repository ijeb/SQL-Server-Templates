-- =======================================================================
-- Create Partitioned Table Template for Azure SQL Data Warehouse Database
-- =======================================================================

IF OBJECT_ID('<schema_name, sysname, dbo>.<table_name, sysname, sample_table>', 'U') IS NOT NULL
    DROP TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_table>
GO

CREATE TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_table>
(
    <column1_name, sysname, c1> <column1_datatype, , int> <column1_nullability, , NOT NULL>,
    <column2_name, sysname, c2> <column2_datatype, , char(10)> <column2_nullability, , NULL>,
    <column3_name, sysname, c3> <column3_datatype, , datetime> <column3_nullability, , NULL>
)
WITH
(
    DISTRIBUTION = HASH (<distribution_column_name, , c1>),
    CLUSTERED COLUMNSTORE INDEX,
    PARTITION (<partition_column_name, , c3> RANGE RIGHT FOR VALUES (<boundary_values, , n>))
)
GO