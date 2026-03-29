# 🐾 PetShop Customer Pareto Analysis & A/B/C Segmentation
### SQL Server + Python | Customer Revenue Segmentation

---

## 📌 Problem Statement

A pet shop accumulates thousands of transactions across hundreds of customers.
Not all customers are equal — a small group of high-value buyers typically drives the majority of revenue.

**The business questions:**
> 1. *"What percentage of our customers is responsible for 80% of our total revenue?"*
> 2. *"How do we classify every customer into actionable revenue tiers?"*

Answering these questions allows the business to:
- Focus retention efforts on the customers that matter most
- Design targeted loyalty programs for top spenders
- Identify which mid-tier customers are closest to becoming VIPs
- Avoid wasting marketing budget on low-impact segments

---

## 🗃️ Dataset

| Column | Description |
|---|---|
| `InvoiceNo` | Unique transaction ID (prefix `C` = cancellation) |
| `StockCode` | Unique product identifier |
| `Description` | Product name |
| `InvoiceDate` | Date & time of transaction |
| `CustomerID` | Unique customer identifier |
| `Quantity` | Units purchased (negative = cancellation) |
| `UnitPrice` | Price per unit |
| `Country` | Customer's country |

> **Revenue formula:** `Quantity × UnitPrice` per line item, aggregated per customer.
> Cancellations (`Quantity < 0` or `UnitPrice < 0`) are excluded from all calculations.

---

## 🧠 Approach

### Step 1 — Aggregate Revenue per Customer (SQL)
Each customer's total revenue is calculated by summing all valid line items.

### Step 2 — Rank & Compute Running Totals (SQL Window Functions)
Customers are ranked from highest to lowest revenue using `ROW_NUMBER()`.
Two key window functions compute:
- **Cumulative revenue** — running total as we move down the ranked list
- **Cumulative revenue share** — what % of total revenue has been collected so far

### Step 3 — Find the Pareto Crossing Point (SQL)
A `DECLARE`d variable `@pct_target_sales` (default `0.80`) sets the target.
The query returns the first customer rank where cumulative revenue share crosses that threshold.

### Step 4 — Assign A/B/C Tiers with CASE WHEN (SQL)
Each customer receives a tier label based on where cumulative revenue share stands at their rank:
- **A** → contributes to the first 80% of total revenue
- **B** → contributes to the 80–95% band
- **C** → contributes to the remaining 5%

### Step 5 — Visualize (Python)
The full ranked dataset is pulled into Python via SQLAlchemy and rendered as a dual-axis Pareto chart with annotated crossing point.

---

## 🛠️ Tech Stack

| Tool | Usage |
|---|---|
| **SQL Server (T-SQL)** | Data aggregation, window functions, CTEs, segmentation |
| **Python** | Data visualization |
| **pandas** | DataFrame manipulation |
| **matplotlib** | Pareto chart (dual-axis) |
| **seaborn** | Chart styling |
| **SQLAlchemy + pyodbc** | SQL Server → Python connection |

---

## 💻 SQL — Part 1: Pareto Crossing Point

```sql
USE petshop
GO
DECLARE @pct_target_sales FLOAT = 0.8;

WITH customer_sales AS (
    SELECT 
        CustomerID, 
        SUM(Quantity * UnitPrice) AS customer_revenue
    FROM sales
    WHERE Quantity > 0 AND UnitPrice > 0
    GROUP BY CustomerID
), 
ranked_by_revenue AS (
    SELECT 
        CustomerID, 
        customer_revenue, 
        ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS rank_customer, 
        COUNT(*) OVER()                                    AS total_customers, 
        SUM(customer_revenue) OVER (
            ORDER BY customer_revenue DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                  AS cum_revenue,
        SUM(customer_revenue) OVER()                       AS total_revenue
    FROM customer_sales
), 
ranked_by_revenue_with_pct AS (
    SELECT 
        CustomerID,
        customer_revenue,
        rank_customer,        
        total_customers, 
        cum_revenue,                             
        total_revenue,
        cum_revenue / total_revenue                        AS cum_sales_share, 
        rank_customer / CAST(total_customers AS FLOAT)     AS cum_pct_customers
    FROM ranked_by_revenue
)
SELECT TOP 1
    rank_customer                               AS number_of_customers, 
    total_customers,
    ROUND(cum_revenue, 2)                       AS cum_revenue, 
    ROUND(total_revenue, 2)                     AS total_revenue,
    @pct_target_sales * 100                     AS target_sales_percent, 
    ROUND(total_revenue * @pct_target_sales, 2) AS target_sales, 
    ROUND(cum_sales_share, 4)                   AS cum_sales_share, 
    ROUND(cum_pct_customers, 4)                 AS cum_pct_customers
FROM ranked_by_revenue_with_pct
WHERE cum_sales_share >= @pct_target_sales
ORDER BY rank_customer ASC;
```

### 📊 Result — Pareto Crossing Point

| number_of_customers | total_customers | cum_revenue | total_revenue | target_sales_percent | target_sales | cum_sales_share | cum_pct_customers |
|---|---|---|---|---|---|---|---|
| 150 | 261 | 93,249.30 | 116,490.24 | 80 | 93,192.19 | 0.8005 | 0.5747 |

> **Reading this:** The first 150 customers (57.5% of the base) account for $93,249 —
> just crossing the 80% revenue threshold. This is the PetShop's **Pareto crossing point**.

---

## 💻 SQL — Part 2: A/B/C Segmentation

```sql
WITH customer_sales AS (
    SELECT 
        CustomerID, 
        SUM(Quantity * UnitPrice) AS customer_revenue
    FROM sales
    WHERE Quantity > 0 AND UnitPrice > 0
    GROUP BY CustomerID
),
ranked_by_revenue AS (
    SELECT 
        CustomerID, 
        customer_revenue,
        ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS rank_customer,
        COUNT(*) OVER ()                                   AS total_customers,
        SUM(customer_revenue) OVER (
            ORDER BY customer_revenue DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                  AS cum_revenue,
        SUM(customer_revenue) OVER ()                      AS total_revenue
    FROM customer_sales
),
ranked_with_pct AS (
    SELECT 
        CustomerID,
        customer_revenue,
        rank_customer,
        total_customers,
        cum_revenue,
        total_revenue,
        cum_revenue / total_revenue                        AS cum_sales_share,
        rank_customer / CAST(total_customers AS FLOAT)     AS cum_pct_customers
    FROM ranked_by_revenue
),
customer_segments AS (
    SELECT 
        CustomerID,
        customer_revenue,
        rank_customer,
        total_customers,
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
    COUNT(CustomerID)                               AS num_customers,
    MIN(total_customers)                            AS total_customers,
    ROUND(COUNT(CustomerID) 
        * 100.0 / MIN(total_customers), 1)          AS pct_customers,
    ROUND(SUM(customer_revenue), 2)                 AS segment_revenue,
    ROUND(SUM(customer_revenue) 
        * 100.0 / MIN(total_revenue), 1)            AS pct_revenue
FROM customer_segments
GROUP BY segment
ORDER BY segment;
```

### 📊 Result — A/B/C Segmentation Summary

| Segment | num_customers | total_customers | pct_customers | segment_revenue | pct_revenue |
|---|---|---|---|---|---|
| 🥇 A | 149 | 261 | 57.1% | $92,854.50 | 79.71% |
| 🥈 B | 57 | 261 | 21.8% | $17,606.25 | 15.11% |
| 🥉 C | 55 | 261 | 21.1% | $6,029.49 | 5.18% |

**Key SQL concepts demonstrated:**
- ✅ Common Table Expressions (CTEs) — multi-step logic, cleanly separated
- ✅ Window functions — `ROW_NUMBER()`, `SUM() OVER()`, `COUNT() OVER()`
- ✅ Explicit window framing — `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
- ✅ Dynamic parameterization — `DECLARE` variable for reusable threshold
- ✅ Conditional segmentation — `CASE WHEN` on a cumulative running metric
- ✅ Data quality filtering — excluding cancellations at source

---

## 💡 Insights & Interpretation

### 1. The PetShop follows a 57/80 rule — not the classic 20/80
The textbook Pareto principle states *"20% of customers = 80% of revenue"*.
Here, **57.1% of customers are needed to reach ~80% of revenue**.
This means revenue is more evenly distributed than a typical retail dataset — no single customer is a dominant outlier. For the business, this signals **healthy revenue diversification** and lower financial dependency on any single buyer.

### 2. Segment B is the hidden growth opportunity 🪙
57 customers contribute 15.1% of revenue. These buyers already have a strong relationship with the store — they are **one targeted loyalty campaign away** from crossing into the A tier. Investing here offers the highest expected return on marketing spend.

### 3. Segment C requires a low-cost service strategy
55 customers generate only 5.18% of revenue — almost the same headcount as B, but 3× less revenue impact. The strategic question is not *"how do we grow them?"* but *"how do we serve them efficiently?"* — automated emails, self-service options, and low-touch retention flows.

### 4. Revenue is concentrated but not fragile
The A segment holds 149 customers — large enough that losing one or two VIPs would not catastrophically impact the business. This contrasts with B2B businesses where 5–10 clients can represent 80% of income.

---

## 📊 Python — Pareto Visualization

```python
import pandas as pd
import urllib
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
from sqlalchemy import create_engine

# Connection
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=LOCALHOST;"
    "DATABASE=petshop;"
    "Trusted_Connection=yes;"
)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

df = pd.read_sql(query, engine)

# Chart
PCT_TARGET = 0.80
crossing  = df[df['cum_sales_share'] >= PCT_TARGET].iloc[0]
cross_x   = crossing['cum_pct_customers']
cross_y   = crossing['cum_sales_share']

sns.set_theme(style="whitegrid")
fig, ax1 = plt.subplots(figsize=(14, 6))
ax2 = ax1.twinx()

ax1.bar(df['cum_pct_customers'], df['customer_revenue'],
        width=1/len(df), color='steelblue', alpha=0.5, label='Customer Revenue')

ax2.plot(df['cum_pct_customers'], df['cum_sales_share'],
         color='firebrick', linewidth=2.5, label='Cumulative Revenue %')

ax2.axhline(y=PCT_TARGET, color='orange', linestyle='--', linewidth=1.5)
ax2.axvline(x=cross_x,   color='green',  linestyle='--', linewidth=1.5)

ax2.annotate(
    f"{cross_x:.1%} of customers\nbring {cross_y:.1%} of revenue",
    xy=(cross_x, cross_y), xytext=(cross_x + 0.05, cross_y - 0.12),
    fontsize=10, color='white',
    bbox=dict(boxstyle='round,pad=0.5', facecolor='firebrick', alpha=0.85),
    arrowprops=dict(arrowstyle='->', color='firebrick')
)

plt.title('Pareto Analysis — PetShop Customer Revenue', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('pareto_petshop.png', dpi=150)
plt.show()
```

<img width="2100" height="900" alt="pareto_petshop" src="https://github.com/user-attachments/assets/889ce2b5-c4bc-4f7d-80d8-46162ea2eb61" />

---

## 🔭 Next Steps

- [ ] Build a **country-level breakdown** of the Pareto distribution
- [ ] Track segment **migration over time** (do B customers become A?)

---

## 👤 Author

**Romaric Nzekeng**    
Businesss Analyst | SQL | Python | Power BI
