# Customer Shopping Behavior Analysis

## 📊 Project Overview

This project analyzes customer shopping behavior using transactional data to uncover actionable insights for business decision-making. The analysis covers spending patterns, customer segmentation, product preferences, discount effectiveness, and subscription behavior. The project follows a complete end-to-end data analytics workflow — from data cleaning in Python to SQL-based analysis in Microsoft SQL Server, and finally to an interactive Power BI dashboard.

---

## 📁 Dataset

- **Source**: Customer shopping transaction records  
- **Records**: 3,900 purchases  
- **Features**: 18 columns including:
  - Demographics: Age, Gender, Location
  - Purchase details: Item, Category, Amount, Season, Size, Color
  - Behavior: Discount applied, Previous purchases, Purchase frequency, Review rating, Shipping type, Subscription status

> ⚠️ Missing values (37 records) were found in the `Review Rating` column and imputed using the median rating per product category.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python (Pandas, NumPy)** | Data loading, EDA, cleaning, feature engineering |
| **Microsoft SQL Server** | Data storage and analytical querying |
| **SQLAlchemy + PyODBC** | Python-to-SQL Server connection |
| **Power BI** | Interactive dashboard creation |
| **Jupyter Notebook** | Exploratory analysis and documentation |
| **PDF + PowerPoint** | Final report and presentation |

---

## 📌 Project Steps

### 1. Data Loading & Initial Exploration (Python)
- Loaded CSV data using Pandas
- Checked data types, missing values, and summary statistics
- Identified 37 missing values in `Review Rating`

### 2. Data Cleaning & Feature Engineering
- Imputed missing ratings using **category-wise median**
- Standardized column names to **snake_case**
- Created new features:
  - `age_group` (Young Adult, Adult, Middle-aged, Senior)
  - `purchase_frequency_days` (mapped from text descriptions)
- Removed redundant `promo_code_used` column (duplicate of `discount_applied`)

### 3. Database Integration
- Connected Python to **Microsoft SQL Server** using SQLAlchemy
- Loaded cleaned dataframe into `customer_behavior` database as `customer` table

### 4. SQL Analysis (10 Business Questions)
Executed structured queries to answer:
- Revenue by gender
- High-spending discount users
- Top 5 products by average rating
- Shipping type comparison
- Subscriber vs. non-subscriber spend
- Discount-dependent products
- Customer segmentation (New / Returning / Loyal)
- Top 3 products per category
- Repeat buyers & subscription likelihood
- Revenue by age group

### 5. Dashboard Creation (Power BI)
Built an interactive dashboard visualizing key metrics:
- Revenue by category, season, and age group
- Discount usage patterns
- Customer segmentation breakdown
- Product performance and ratings

### 6. Reporting & Presentation
- Compiled findings into a **PDF report**
- Created a **PowerPoint presentation** for stakeholders

---

## 📈 Dashboard Preview

The Power BI dashboard includes:
- Revenue trends
- Customer segment distribution
- Top-performing products
- Discount effectiveness
- Subscription impact on spending

<img width="1445" height="807" alt="2" src="https://github.com/user-attachments/assets/92d92cf7-c9b4-4e96-b8f6-cc5dd1f1aa2b" />

---

## 🔍 Key Results Summary

| Question | Insight |
|----------|---------|
| Revenue by gender | [Insight from your SQL output] |
| Subscribers vs. non-subscribers | Subscribers spent ~$59.50 avg vs. non-subscribers ~$59.87 |
| Customer segments | 3,116 Loyal, 701 Returning, 83 New customers |
| Discount-dependent products | Hats (50%), Sneakers (49.7%), Coats (49.1%) |
| Repeat buyers & subscriptions | 958 subscribers out of 3,476 repeat buyers |
| Top product categories by purchases | Accessories, Clothing, Footwear, Outwear |

---

## 🚀 How to Run This Project

### Prerequisites
- Python 3.12
- Microsoft SQL Server (local)
- Power BI Desktop (for dashboard)
- Required Python libraries:
  ```bash
  pip install pandas numpy matplotlib sqlalchemy pyodbc
  ```

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/knromaric/customer_analysis_python_sql_powerBI.git
   cd customer_analysis_python_sql_powerBI
   ```

2. **Prepare the database**
   - Run `1_creating_sql_server_DB.sql` in SQL Server Management Studio (SSMS)
   - This creates `customer_behavior` database

3. **Run Python EDA & Load Data**
   - Open `customer_behavior_analysis.ipynb` in Jupyter Notebook
   - Execute all cells to:
     - Load and clean data
     - Connect to SQL Server
     - Load the cleaned dataframe into the database

4. **Run SQL Analysis**
   - Execute `2_Analyzing_customer_behavior.sql` in SSMS
   - Review query results

5. **View Power BI Dashboard**
   - Open the `.pbix` file (if included)
   - Refresh data connection to point to your SQL Server instance

6. **Review Final Report**
   - Open `Customer Shopping Behavior Analysis.pdf`

---

## 👩‍💻 Author

**Romaric Nzekeng**  
Business Analyst | SQL | Python | Power BI  
[GitHub](https://github.com/knromaric)
