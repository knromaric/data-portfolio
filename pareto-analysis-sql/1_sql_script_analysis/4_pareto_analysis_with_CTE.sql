/***********************************
	Pareto Analysis Using CTEs
***********************************/

USE petshop
GO

DECLARE @pct_target_sales FLOAT = 0.8;

WITH customer_sales AS (
	SELECT 
		CustomerID, 
		SUM(Quantity * UnitPrice) customer_revenue
	FROM sales
	GROUP BY CustomerID
), 
ranked_by_revenue AS (
	SELECT 
		CustomerID, 
		customer_revenue, 
		ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS rank_customer, 
		COUNT(*) OVER() AS total_customer, 
		SUM(customer_revenue) 
			OVER(ORDER BY customer_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
		SUM(customer_revenue) OVER() AS total_revenue
	FROM customer_sales
), 
ranked_by_revenue_with_pct AS (
	SELECT 
		CustomerID,
		customer_revenue,
		rank_customer,        
		total_customer, 
		cum_revenue,                             
		total_revenue,
		cum_revenue / total_revenue AS cum_sales_share, 
		rank_customer / CAST(total_customer AS FLOAT) AS cum_pct_customers
	FROM ranked_by_revenue
)
SELECT TOP 1
    rank_customer        AS number_of_customers,
    total_customer       AS total_customers,
    ROUND(cum_revenue, 2)           AS cum_revenue,
    ROUND(total_revenue, 2)         AS total_revenue,
    @pct_target_sales * 100         AS target_sales_percent,
    ROUND(total_revenue * @pct_target_sales, 2) AS target_sales,
    ROUND(cum_sales_share, 4)       AS cum_sales_share,
    ROUND(cum_pct_customers, 4)     AS cum_pct_customers
FROM ranked_by_revenue_with_pct
WHERE cum_sales_share >= @pct_target_sales;
GO


/*********************************************************************************
	CUSTOMER SEGMENTATION CTEs

	Let's segment our data by cumulative sales share: 

 A (VIPs) — few but mighty Top 0–80% of cumulative revenue
 B (Mid-value) — worth nurturing 80–95% of cumulative revenue
 C (Low-value) — large in number, small in impact 95–100% of cumulative revenue
*********************************************************************************/


WITH customer_sales AS (
	SELECT 
		CustomerID, 
		SUM(Quantity * UnitPrice) customer_revenue
	FROM sales
	GROUP BY CustomerID
), 
ranked_by_revenue AS (
	SELECT 
		CustomerID, 
		customer_revenue, 
		ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS rank_customer, 
		COUNT(*) OVER() AS total_customer, 
		SUM(customer_revenue) 
			OVER(ORDER BY customer_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
		SUM(customer_revenue) OVER() AS total_revenue
	FROM customer_sales
), 
ranked_with_pct AS (
	SELECT 
		CustomerID,
		customer_revenue,
		rank_customer,        
		total_customer, 
		cum_revenue,                             
		total_revenue,
		cum_revenue / total_revenue AS cum_sales_share, 
		rank_customer / CAST(total_customer AS FLOAT) AS cum_pct_customers
	FROM ranked_by_revenue
),
customer_segments AS (
    SELECT 
        CustomerID,
        customer_revenue,
        rank_customer,
        total_customer,
		total_revenue,
        cum_sales_share,
        cum_pct_customers,
        CASE 
            WHEN cum_sales_share <= 0.80 THEN 'A'
            WHEN cum_sales_share <= 0.95 THEN 'B'
            ELSE                              'C'
        END AS segment
    FROM ranked_with_pct
)
SELECT 
    segment,
    COUNT(CustomerID)                            AS num_customers,
    MIN(total_customer)                         AS total_customers,
    ROUND((COUNT(CustomerID) / CAST(MIN(total_customer) AS FLOAT) * 100.0), 1)       AS pct_customers,
    ROUND(SUM(customer_revenue), 2)              AS segment_revenue,
    ROUND(SUM(customer_revenue) * 100.0 / CAST(MIN(total_revenue) AS FLOAT), 2)         AS pct_revenue
FROM customer_segments
GROUP BY segment
ORDER BY segment;