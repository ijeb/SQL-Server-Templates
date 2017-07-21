-- =========================================
-- Create Graph Edge Template
-- =========================================

IF OBJECT_ID('<schema_name, sysname, dbo>.<table_name, sysname, sample_edgetable>', 'U') IS NOT NULL
  DROP TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_edgetable>
GO

CREATE TABLE <schema_name, sysname, dbo>.<table_name, sysname, sample_edgetable>
(
    -- Columns are optional for Edge Tables
    --
    <column1_name, sysname, c1> <column1_datatype, , int> <column1_nullability, , NOT NULL>,
    <column2_name, sysname, c2> <column2_datatype, , char(10)> <column2_nullability, , NULL>,
    <column3_name, sysname, c3> <column3_datatype, , datetime> <column3_nullability, , NULL>,

    -- Unique index on $node_id is required
    INDEX ix_graphid UNIQUE ($node_id),

    -- indexes on $from_id and $to_id support faster lookups
    INDEX ix_fromid ($from_id),
    INDEX ix_toid ($to_id)
)
AS EDGE
GO
