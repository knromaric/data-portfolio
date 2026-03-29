/*======================================================================
	Pareto Analysis: 
	Where do the majority of our Sales come from? from which customers
========================================================================*/

USE petshop
GO


--*****************************************
-- Create a view "sales_v1" which summarizes
-- Sales by CustomerID
--*****************************************
CREATE OR ALTER VIEW dbo.sales_v1
AS
SELECT 
	CustomerID, 
	SUM(Quantity * UnitPrice) customer_revenue
FROM sales
GROUP BY CustomerID;
GO


--********************************************
-- Create a view "sales_v2" with columns: 
-- CustomerID, customer_revenue, Cum_customers
-- total_customers, cum_revenue, total_revenue
--********************************************

CREATE OR ALTER VIEW dbo.sales_v2
AS
SELECT 
	CustomerID, 
	customer_revenue, 
	ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS rank_customer, 
	COUNT(*) OVER() AS total_customer, 
	SUM(customer_revenue) 
		OVER(ORDER BY customer_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
	SUM(customer_revenue) OVER() AS total_revenue
FROM sales_v1
GO


--**********************************************
-- Create a view "sales_v3" with columns: 
-- CustomerID, customer_revenue, Cum_customers
-- total_customers, cum_revenue, total_revenue
-- cum_sales_share, cum_pct_customers
--**********************************************
CREATE OR ALTER VIEW dbo.sales_v3 
AS
SELECT 
	CustomerID,
	customer_revenue,
	rank_customer,        
	total_customer, 
	cum_revenue,                             
	total_revenue,
	cum_revenue / total_revenue AS cum_sales_share, 
    rank_customer / CAST(total_customer AS FLOAT) AS cum_pct_customers
FROM sales_v2
GO

/* ============== INSIGHTS ==============================================================
	- 80% of revenue come from 57% of of our customers which represents (150 customers)
	- 50% of our sales come from 30% of our customers which represents (79 customers)
=========================================================================================*/