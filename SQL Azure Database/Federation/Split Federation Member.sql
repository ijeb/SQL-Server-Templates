-- =========================================================================
-- Split federation member template for a Azure SQL Database
-- This script will run only in the context of the federation root database.
--
-- ***IMPORTANT***
--
-- The Federations feature will be retired with Web and Business service 
-- tiers. Consider deploying solutions utilizing Elastic Scale to maximize 
-- scalability, flexibility, and performance. For more information about 
-- Elastic Scale see http://go.microsoft.com/fwlink/p/?LinkId=517820
--
-- =========================================================================

USE FEDERATION ROOT WITH RESET
GO

ALTER FEDERATION <Federation_Name, sysname, > SPLIT AT 
(<Distribution_Name, sysname, > = <Boundary_Value, keytype, >)
GO
