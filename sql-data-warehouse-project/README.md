# 🏗️ SQL Data Warehouse Project

## 📊 Project Overview

This project showcases a complete **data warehousing solution** built using **Microsoft SQL Server**. Following the **Medallion Architecture** (Bronze → Silver → Gold), I transformed raw source data into a clean, business-ready analytical data model. The project demonstrates end-to-end ETL processes, data quality testing, and exploratory analysis — essential skills for any data engineering or analytics role.

---

## 📁 Dataset

The data comes from multiple source systems (CRM and ERP), simulating a real-world scenario where data must be integrated from disparate sources.

| Source System | Tables | Description |
|---------------|--------|-------------|
| **CRM** | `cust_info`, `prd_info`, `sales_details` | Customer information, product data, sales transactions |
| **ERP** | `cust_az12`, `loc_a101`, `px_cat_g1v2` | Customer details, location data, product categories |

**Data Volume:** ~50,000+ records across all tables  
**Time Coverage:** Historical sales data spanning multiple years

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Microsoft SQL Server** | Data warehouse database engine |
| **T-SQL** | Data definition (DDL) and manipulation (DML) |
| **SQL Server Management Studio (SSMS)** | Query development and management |
| **Git** | Version control |

---

## 🧱 Data Architecture (Medallion Layers)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Bronze    │────▶│   Silver    │────▶│    Gold     │
│  (Raw Data) │     │  (Cleaned)  │     │ (Business)  │
└─────────────┘     └─────────────┘     └─────────────┘
```

### 1. 🥉 Bronze Layer (Raw Data)
- Stores data exactly as received from source CSV files
- No transformations applied
- Tables: `bronze.crm_cust_info`, `bronze.crm_prd_info`, `bronze.crm_sales_details`, `bronze.erp_cust_az12`, `bronze.erp_loc_a101`, `bronze.erp_px_cat_g1v2`

### 2. 🥈 Silver Layer (Cleaned & Enriched)
- Data type conversions and standardization
- Handling NULL values and duplicates
- Data integration from multiple sources
- Date validation and formatting
- Tables: `silver.crm_cust_info`, `silver.crm_prd_info`, `silver.crm_sales_details`, `silver.erp_cust_az12`, `silver.erp_loc_a101`, `silver.erp_px_cat_g1v2`

### 3. 🥇 Gold Layer (Business-Ready)
- Star schema for analytics
- **Dimensions:** `dim_customers`, `dim_products`
- **Fact Table:** `fact_sales`
- Business-friendly column names and aggregations

---

## 📂 Repository Structure

```
sql-data-warehouse-project/
│
├── scripts/
│   ├── init_database.sql              # Create database and schemas
│   ├── ddl_bronze.sql                 # Bronze table definitions
│   ├── sp_load_bronze.sql             # Stored procedure: Load Bronze from CSVs
│   ├── ddl_silver.sql                 # Silver table definitions
│   ├── proc_load_silver.sql           # Stored procedure: ETL Bronze → Silver
│   ├── ddl_gold.sql                   # Gold layer views (star schema)
│   ├── report_customers.sql           # Customer analytics view
│   └── report_products.sql            # Product analytics view
│
├── analysis/
│   └── exploratory_data_analysis.sql  # Business insights queries
│
├── tests/
│   ├── quality_checks_silver.sql      # Silver layer data quality tests
│   └── quality_checks_gold.sql        # Gold layer integrity tests
│
└── README.md                          # Project overview (this file)
```

---

## 🔍 Analysis & Insights

After building the warehouse, I performed exploratory analysis on the Gold layer to answer key business questions:


### Ranking Analysis Performed

- Top 5 products by revenue
- Bottom 5 products by revenue
- Top 5 sub-categories by revenue
- Top 10 customers by revenue
- Customers with fewest orders

### Customer Segmentation

The `report_customers` view segments customers into:
- **VIP:** Lifespan ≥ 12 months AND total sales > $5,000
- **Regular:** Lifespan ≥ 12 months AND total sales ≤ $5,000
- **New:** Lifespan < 12 months

### Product Segmentation

The `report_products` view segments products into:
- **High-Performer:** Total sales > $50,000
- **Mid-Range:** Total sales between $10,000 - $50,000
- **Low-Performer:** Total sales < $10,000

---

## ✅ Data Quality & Testing

I implemented comprehensive data quality checks in the `tests/` folder:

### Silver Layer Tests (`quality_checks_silver.sql`)
- **Null/duplicate primary key checks**
- **String trimming validation** (no leading/trailing spaces)
- **Data standardization** (marital status, gender, product lines)
- **Invalid date detection** (end_date < start_date)
- **Referential integrity** (foreign key checks)
- **Business rule validation** (Sales = Quantity × Price)

### Gold Layer Tests (`quality_checks_gold.sql`)
- **Surrogate key uniqueness** in dimension tables
- **Referential integrity** between fact and dimension tables
- **Data integration validation** (CRM vs. ERP gender consistency)

---

## 🚀 How to Run This Project

### Prerequisites
- **Microsoft SQL Server** (2019 or later)
- **SQL Server Management Studio (SSMS)** or Azure Data Studio
- **Git** (to clone the repository)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/knromaric/data-portfolio.git
   cd data-portfolio/sql-data-warehouse-project
   ```

2. **Initialize the Database**
   - Open `scripts/init_database.sql` in SSMS
   - Execute to create `DataWarehouse` database and `bronze`, `silver`, `gold` schemas

3. **⚠️ Update File Paths**
   - Open `scripts/sp_load_bronze.sql`
   - Update all `BULK INSERT` file paths to point to your local CSV file locations
   - *Note: Source CSV files are not included in this repository*

4. **Load Bronze Layer**
   ```sql
   EXEC bronze.load_bronze;
   ```

5. **Load Silver Layer**
   ```sql
   EXEC silver.load_silver;
   ```

6. **Create Gold Layer Views**
   - Execute `scripts/ddl_gold.sql` to create dimension and fact views
   - Execute `scripts/report_customers.sql` and `scripts/report_products.sql` for analytics views

7. **Run Quality Checks**
   - Execute `tests/quality_checks_silver.sql`
   - Execute `tests/quality_checks_gold.sql`
   - *Expected result: No rows returned = all checks pass*

8. **Run Exploratory Analysis**
   - Execute `analysis/exploratory_data_analysis.sql` to generate business insights

---

## 📈 Sample Queries

### Top 5 Products by Revenue
```sql
SELECT TOP 5
    dp.product_name, 
    SUM(fs.sales_amount) total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp 
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC;
```

### Customer Segmentation Summary
```sql
SELECT 
    customer_segment,
    COUNT(*) AS customer_count,
    AVG(total_sales) AS avg_sales
FROM gold.report_customers
GROUP BY customer_segment;
```

---

## 🧠 Key Learnings

- **Medallion Architecture** provides clear separation of concerns and data lineage
- **Stored procedures** enable reproducible, automated ETL processes
- **Data quality tests** catch issues early and ensure reliable analytics
- **Star schema design** simplifies querying for business users
- **Window functions** (e.g., `LEAD`, `ROW_NUMBER`) are powerful for data transformation

---

## 👨‍💻 Author

**Romaric Nzekeng**  
Business Analyst | SQL | PYTHON | POWER BI

---
