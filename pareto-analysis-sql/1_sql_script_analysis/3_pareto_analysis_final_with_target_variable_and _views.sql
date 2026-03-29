USE petshop
GO 

-- declaring a variable 
DECLARE @pct_target_sales FLOAT = 0.8;

SELECT TOP 1
    rank_customer        AS number_of_customers,
    total_customer       AS total_customers,
    ROUND(cum_revenue, 2)           AS cum_revenue,
    ROUND(total_revenue, 2)         AS total_revenue,
    @pct_target_sales * 100         AS target_sales_percent,
    ROUND(total_revenue * @pct_target_sales, 2) AS target_sales,
    ROUND(cum_sales_share, 4)       AS cum_sales_share,
    ROUND(cum_pct_customers, 4)     AS cum_pct_customers
FROM dbo.sales_v3
WHERE cum_sales_share >= @pct_target_sales
GO


/***************************** INSIGHTS *************************************
	- 50% of total sales is equal to 58245.12. and 50% of total sales
	come from 30% of customers which represent a total of 79 customers
	over 261 customers.

	- 80% of total sales is equal to 93192.192. and 80% of total sales
	come from 57% of customers which represent a total of 150 customers
	over 261 customers.
*****************************************************************************/