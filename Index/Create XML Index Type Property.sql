-- =============================================
-- Create XML Index Type PROPERTY Template
-- =============================================
-- Creates a secondary XML index of type PROPERTY
-- on an XML column using a primary XML index on 
-- the XML column

USE	<database_name, sysname, myDatabase>
GO

IF EXISTS (
	SELECT	* 
    FROM	sys.xml_indexes 
    WHERE	name = '<xml_index_name, sysname, myPropertyXmlIndex>' AND
			object_id = OBJECT_ID ('<schema_name, sysname, myDatabaseSchema>.<table_name, sysname, myTable>')
	)
DROP INDEX <xml_index_name, sysname, myPropertyXmlIndex>
	ON <schema_name, sysname, myDatabaseSchema>.<table_name, sysname, myTable>
GO

CREATE XML INDEX <xml_index_name, sysname, myPropertyXmlIndex>
ON <schema_name, sysname, myDatabaseSchema>.<table_name, sysname, myTable> 
(
	<xml_column_name, sysname, myXmlColumn>
)
USING XML INDEX <xml_index_name, sysname, myPrimaryXmlIndex>
FOR PROPERTY
GO