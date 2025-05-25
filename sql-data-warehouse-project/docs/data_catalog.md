# Data Dictionary for Gold Layer   

## Overview   
The Gold Layer is the business-level data representation structured to support analytical and reporting use cases. It consists of 
**dimension tables** and **fact tables** for specific business metrics   
<hr>   

### 1. gold.dim_customers    

+ **purpose**: Stores details enriched with demographics and geographic data   

+ **Columns**:

| **Column Name** | **Data Type** | **Description**|   
|-----------------|---------------|----------------|
|customer_key|INT|Surrogate key uniquely identifying each customer record in the dimension table.|

