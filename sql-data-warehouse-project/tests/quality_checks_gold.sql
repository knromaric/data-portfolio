/*
================================================================================
Quality Checks
================================================================================
Script Purpose: 
	This script performs quality checks to validate the integrity, consistency, 
	and accuracy of the Gold Layer. These Checks ensure: 
	- Uniqueness of surrogate keys in dimension tables.
	- Referential integrity between fact and dimension tables
	- Validation of relationships in the data model for analytical purposes

Usage Notes: 
	- Run these checks after loading data in Silver Layer
	- Investigate and resolve and discrepancies found during checks


*/

-- ===========================================
-- Checking 'gold.dim_customers'
-- ===========================================
-- check for uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 

SELECT 
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Data integration checks 
-- 2 columns with the same information (customer gender information)
-- master data is the CRM information 

SELECT DISTINCT 
	ci.cst_gndr,
	ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid
ORDER BY 1, 2;

--** fix data integration of customer gender**
SELECT DISTINCT 
	ci.cst_gndr,
	ca.gen, 
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gendre info
		 ELSE COALESCE(ca.gen, 'n/a') -- if NULL then 'n/a'
	END gen_new
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid
ORDER BY 1, 2;

-- Check the quality of the view gold.dim_customers
SELECT distinct gender FROM gold.dim_customers;

SELECT * FROM gold.dim_customers;

-- Check the quality of the view gold.dim_products
SELECT * FROM gold.dim_products;

-- Check the quality of the view gold.fact_sales
select * from gold.fact_sales;

-- Fact check: check if all dimension tables can successfully join to the fact table 
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR
	p.product_key IS NULL;
