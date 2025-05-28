/*
====================================================================================================
Product Report
====================================================================================================
Purpose: 
	- This report consolidates key Product metrics and behaviors

Highlights: 
	1. Gathers essential fields such as product name, category, subcategory, and cost
	2. Segments products by revenue to identity High-performers, Mid-Range, or Low-performers
	3. Aggregates product-level metrics: 
		- total orders 
		- total sales
		- total quantity sold
		- total customer (unique) 
		- lifespan (in months)
	4. Calculates valuable KPIs: 
		- recency (months since last order)
		- average order value
		- average monthly spend
====================================================================================================
*/

CREATE OR ALTER VIEW report_products AS
WITH base_query AS
(
-------------------------------------------------------------------------
-- Base Query: retrieves core columns from tables 
-------------------------------------------------------------------------
	SELECT 
		s.order_number,
		s.order_date,
		s.customer_key,
		s.quantity, 
		s.sales_amount,
		p.product_key,
		p.category,
		p.subcategory, 
		p.product_name,
		p.cost
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p 
		ON p.product_key = s.product_key
	WHERE s.order_date IS NOT NULL -- only consider valid sales dates
),

product_aggregation AS
(
	SELECT 
		product_key,
		category,
		subcategory, 
		product_name,
		cost, 
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan, 
		MAX(order_date) AS last_sale_date, 
		COUNT(DISTINCT order_number) AS total_orders, 
		COUNT(DISTINCT customer_key) AS total_customers, 
		SUM(sales_amount) AS total_sales, 
		SUM(quantity) total_quantity, 
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) avg_selling_price
	FROM base_query
	GROUP BY 
		product_key,
		category,
		subcategory, 
		product_name,
		cost
)

-------------------------------------------------------------------------
-- FINAL Query: Combines all product results into one output
-------------------------------------------------------------------------
SELECT 
	product_key,
	category,
	subcategory, 
	product_name,
	cost, 
	last_sale_date, 
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months, 
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment, 
	lifespan, 
	total_orders,
	total_sales, 
	total_quantity, 
	total_customers, 
	avg_selling_price, 
	-- compute Average Order Revenue (AOR) 
	CASE
		WHEN  total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END avg_order_value,

	-- compute Average Monthly Spend
	CASE
		WHEN  lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END avg_monthly_spend
FROM product_aggregation;
