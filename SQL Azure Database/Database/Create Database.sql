-- ===================================================================================================================================
-- Create database template for Azure SQL Database and Azure SQL Data Warehouse Database
--
-- This script will only run in the context of the master database. To manage this database in 
-- SQL Server Management Studio, either connect to the created database, or connect to master.
--
-- SQL Database is a relational database-as-a-service that makes tier-1 capabilities easily accessible 
-- for cloud architects and developers by delivering predictable performance, scalability, business 
-- continuity, data protection and security, and near-zero administration � all backed by the power 
-- and reach of Microsoft Azure.
--
-- SQL Database is available in the following service tiers: Basic, Standard, Premium , DataWarehouse, Web (Retired) 
-- and Business (Retired).
-- Standard is the go-to option for getting started with cloud-designed business applications and 
-- offers mid-level performance and business continuity features. Performance objectives for Standard 
-- deliver predictable per minute transaction rates.
--
-- See http://go.microsoft.com/fwlink/p/?LinkId=306622 for more information about Azure SQL Database.
-- 
-- See http://go.microsoft.com/fwlink/?LinkId=787140 for more information about Azure SQL Data Warehouse.
--
-- See http://go.microsoft.com/fwlink/p/?LinkId=402063 for more information about CREATE DATABASE for Azure SQL Database.
--
-- See http://go.microsoft.com/fwlink/?LinkId=787139 for more information about CREATE DATABASE for Azure SQL Data Warehouse Database.
-- ===================================================================================================================================

 
CREATE DATABASE <Database_Name, sysname, Database_Name> COLLATE <collation_Name, sysname, SQL_Latin1_General_CP1_CI_AS> 
	(
	  EDITION = '<EDITION, , Standard>',
	  SERVICE_OBJECTIVE='<SERVICE_OBJECTIVE,,S0>',
	  MAXSIZE = <MAX_SIZE,,1024 GB>
	)

GO
