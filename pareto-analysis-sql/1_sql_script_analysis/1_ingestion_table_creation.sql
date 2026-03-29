/* =========================================================
	Creating table for CSV file
============================================================*/
-- CREATE DATABASE 
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'petshop')
BEGIN
    CREATE DATABASE petshop;
END;
GO

-- use the Database
USE petshop;
GO

-- Create table "sales"
IF OBJECT_ID(N'dbo.[sales]', N'U') IS NULL
BEGIN
CREATE TABLE sales (
	InvoiceNo NVARCHAR(50) NULL,      
	StockCode NVARCHAR(50) NULL,       
	Description NVARCHAR(255) NULL,    
	InvoiceDate DATE NULL,              
	CustomerID INT NULL,                
	Quantity INT NULL,                   
	UnitPrice DECIMAL(18,2) NULL,               
	Country NVARCHAR(100) NULL           
)
END;
GO


-- Insert data in table "Sales" 
BEGIN TRY
	BEGIN TRANSACTION;
	BULK INSERT sales
	FROM 'C:\Users\k-zero\Desktop\pareto-analysis-sql\data\pet_shop_sales.csv'
	WITH (
		FORMAT = 'CSV',              -- Specifies CSV format [citation:1][citation:8]
		FIRSTROW = 2,                 -- Skip header row if your CSV has headers [citation:10]
		FIELDTERMINATOR = ',',        -- Comma delimiter for CSV
		ROWTERMINATOR = '\n',         -- Row terminator (use '\r\n' for Windows files)
		TABLOCK                       -- Improves performance
	);

	COMMIT TRANSACTION;
	PRINT 'Import completed successfully!';
	SELECT 'Rows imported ' + CAST(@@ROWCOUNT AS VARCHAR(10));
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION; 
	PRINT 'Error Occured: ' + ERROR_MESSAGE();
END CATCH