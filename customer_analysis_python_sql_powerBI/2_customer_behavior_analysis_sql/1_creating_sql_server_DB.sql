-- Creating the customer_behavior database 

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name='customer_behavior')
BEGIN
	CREATE DATABASE customer_behavior
END;
GO

-- Use the database
USE customer_behavior; 
GO 

