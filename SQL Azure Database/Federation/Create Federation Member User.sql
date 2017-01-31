-- ===============================================================
-- Create User as DBO template for Azure SQL Database
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

CREATE USER <user_name, sysname, user_name>	
GO

-- Add user to the database owner role
EXEC sp_addrolemember N'db_owner', N'<user_name, sysname, user_name>'
GO
