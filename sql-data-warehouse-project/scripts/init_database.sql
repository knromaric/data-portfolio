/*
==========================================================
Create Database and Schemas
==========================================================
Script purpose: 
	This script create a new database named 'DataWarehouse' after checking if it already exists.
	if the database exists, it  is dropped and recreated. Additionally, the script sets up three 
	schemas within the database:'bronze','silver', and 'gold'

Warning:
	Running this script will drop the entire 'Datawarehouse' database if it exists. 
	All data int the database will be permanently deleted. Proceed with caution
	and ensure your have backups before running this script.
*/

USE master;
go 

-- Drop and recreate the DataWarehouse if exists 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;
GO

-- Create the 'Datawarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create SCHEMA
CREATE SCHEMA bronze; 
GO
CREATE SCHEMA silver; 
GO
CREATE SCHEMA gold; 
GO
