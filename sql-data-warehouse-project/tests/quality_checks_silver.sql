/*
=====================================================
		QUALITY CHECKS IN THE SILVER LAYER
=====================================================
Script purpose: 
	This script aims at performing various quality checks for data consistency, accuracy, 
	and standardization across the silver schemas. It includes checks for: 
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields
	- Data standardization and consistency.
	- Invalid date ranges and orders.
	- Data consistency between related fields.

	Usage Notes: 
		- Run this checks After data loading in silver layer.
		- Investigate and resolve and discrepancies found during checks
*/

--===================================================
--    TABLE: silver.crm_cust_info
--===================================================


-- Check of Nulls and Duplicates in Primary Key
-- Expectation: No Result 

SELECT 
cst_id, 
count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
having count(*) >1 OR cst_id IS NULL;

-- Check for unwanted spaces in string 
-- Expectation: No Result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Data Standardization &  Consistency

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

-- check the whole table 
SELECT * FROM silver.crm_cust_info;


--===================================================
--    TABLE: silver.crm_prd_info
--===================================================


-- check for nulls or duplicates in primary key
-- Expectation: No Result
SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces in product name column (prd_nm)
-- EXPECTATION: No Result
SELECT 
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Checks for Nulls OR negative Numbers (prd_cost)
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & consistency (prd_line column)
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Checking the quality of the Start and end date (prd_start_dt, prd_end_dt)
-- PROBLEM : end_date < start_date and there are overlaps 
-- Check for Invalid Date Orders

SELECT * 
FROM silver.crm_prd_info
where prd_end_dt < prd_start_dt;

-- final look at the table silver.crm_prd_info
SELECT * 
FROM silver.crm_prd_info;


--===================================================
--    TABLE: silver.crm_sales_details
--===================================================

-- Checks for unwanted spaces 
-- EXPECTATION: No Result
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- checks for the integrity of sls_prd_key
-- Expectations: No Results
SELECT 
	* 
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);


-- check for the integrity of cust_id
-- Expectations: No Results
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- CHECK FOR INVALID DATES

-- Check of Invalid Date Orders

SELECT 
	sls_order_dt, 
	sls_ship_dt, 
	sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR 
	  sls_order_dt > sls_due_dt  OR
	  sls_ship_dt > sls_due_dt;

-- Check data consistency: between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, Zero or negative

SELECT DISTINCT
	sls_sales, 
	sls_quantity, 
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL 
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0 
ORDER BY sls_sales, sls_quantity, sls_price;

-->> finally check the whole table 
SELECT * 
FROM silver.crm_sales_details;



--===================================================
--    TABLE: silver.erp_cust_az12
--===================================================

-- Identify Out-Of-Range Dates 

SELECT 
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR 
	bdate > GETDATE();

-- Data Standardization & consistency

SELECT distinct 
	gen
FROM silver.erp_cust_az12;

-- final check at the table

SELECT *
FROM silver.erp_cust_az12;

--===================================================
--    TABLE: silver.erp_loc_a101
--===================================================

-- Data Standardization & consistency

SELECT 
	distinct cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT 
	*
FROM silver.erp_loc_a101;

--===================================================
--    TABLE: silver.erp_loc_a101
--===================================================

SELECT * 
FROM silver.erp_px_cat_g1v2;
