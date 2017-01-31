-- ===============================================================
-- Create federated table template Azure SQL Database 
--
-- ***IMPORTANT***
--
-- The Federations feature will be retired with Web and Business 
-- service tiers. Consider deploying solutions utilizing Elastic 
-- Scale to maximize scalability, flexibility, and performance.  
-- For more information about Elastic Scale see 
-- http://go.microsoft.com/fwlink/p/?LinkId=517820
--
-- ===============================================================

IF OBJECT_ID('<schema_name, sysname, dbo>.<table_name, sysname, sample_table>', 'U') IS NOT NULL
  DROP TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_table>
GO

CREATE TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_table>
(
       <columns_in_primary_key, , c1> <column1_datatype, , bigint> <column1_nullability,, NOT NULL>, 
       <column2_name, sysname, c2> <column2_datatype, , char(10)> <column2_nullability,, NULL>, 
       <column3_name, sysname, c3> <column3_datatype, , datetime> <column3_nullability,, NULL>, 
    CONSTRAINT <contraint_name, sysname, PK_sample_table> PRIMARY KEY (<columns_in_primary_key, , c1>)
) FEDERATED ON (<Distribution_Name, sysname, > = <column_Name, sysname, >)
GO
