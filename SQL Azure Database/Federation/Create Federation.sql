-- ===============================================================
-- Create federation template for a Azure SQL Database
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

CREATE FEDERATION <Federation_Name, sysname, Federation_Name>
(<Distribution_Name, sysname, Distribution_Name> <Data_Type, systype, BIGINT> RANGE)
GO
