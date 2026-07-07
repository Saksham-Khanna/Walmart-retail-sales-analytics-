# 🛒 Walmart Retail Sales SQL Analytics

An end-to-end, production-grade SQL portfolio project designed to demonstrate advanced database design, data manipulation, and business intelligence extraction. 

This project goes beyond basic `SELECT` statements, acting as a real-world business case study. It mimics the analytical rigor expected at top-tier consulting firms (Deloitte, EY, ZS Associates) and FAANG companies by translating raw data into actionable C-suite insights.

---

## 🎯 Objectives
1. **Database Architecture:** Design and deploy a normalized Star Schema from a flat data file to optimize analytical querying.
2. **Advanced SQL Utilization:** Employ complex SQL concepts including Window Functions, CTEs, Correlated Subqueries, and multi-layered Aggregations.
3. **Macroeconomic Analysis:** Determine the statistical impact of external factors (CPI, Unemployment, Fuel Prices) on retail sales.
4. **Actionable BI:** Move beyond data reporting to data interpretation by providing concrete strategic recommendations.

---

## 📊 Dataset
The dataset utilized is the **Walmart Store Sales Forecasting** dataset. 
- **Size:** 6,435 weekly aggregated sales records across 45 unique stores.
- **Features:** `Store ID`, `Date`, `Weekly Sales`, `Holiday Flag`, `Temperature`, `Fuel Price`, `CPI`, `Unemployment`.
- **Domain:** Retail, Macroeconomics, and Supply Chain.

---

## 🗄️ Database Design (Star Schema)
To demonstrate data engineering best practices, the flat CSV file was normalized into a Star Schema. 

*   **`staging_sales`**: A temporary landing table for raw CSV bulk insertion using `LOAD DATA INFILE`.
*   **`dim_stores`**: Dimension table storing unique store entities.
*   **`dim_calendar`**: Dimension table containing time intelligence (Weeks, Months, Quarters, Day of Week) derived from the raw string dates.
*   **`fact_sales`**: The core quantitative table containing the `weekly_sales` metrics and macroeconomic indicators, linked via Foreign Keys to the dimensions. 

*Performance Optimization:* Indexes were explicitly created on `store_id` and `cal_date` within the fact table to accelerate `JOIN` and `WHERE` clause performance during heavy analytical workloads.

---

## 🛠️ SQL Concepts Mastered
This repository heavily utilizes the following advanced SQL functions (MySQL 8+):

- **Window Functions:** `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `LAG()`, `LEAD()`, `CUME_DIST()`, `AVG() OVER()`
- **Complex Joins & Subqueries:** `INNER JOIN`, Correlated Subqueries, `IN` / `EXISTS` clauses.
- **Common Table Expressions (CTEs):** Breaking down complex logic (e.g., Month-over-Month growth, Percentile calculations) into readable blocks.
- **Aggregation & Grouping:** `GROUP BY`, `HAVING`, mathematical variances (`MAX() - MIN()`).
- **Data Definition & Manipulation:** `CREATE TABLE`, `ALTER TABLE`, `INSERT IGNORE`, `DELETE`, `LOAD DATA INFILE`.
- **Views:** Abstracting complex logic into standardized `CREATE VIEW` objects for PowerBI / Tableau integration.

---

## ❓ Key Business Questions Answered
The queries in this project answer over 40 distinct business problems across 4 primary domains:

1. **Store Performance:** Which stores consistently underperform? What is the sales variance between the best and worst stores?
2. **Holiday Impact:** What is the quantifiable percentage lift of a holiday week? Which stores benefit the most?
3. **Macroeconomic Sensitivities:** Do regions with unemployment > 9% show flattened sales? How does a spike in CPI impact consumer purchasing?
4. **Trend Analysis:** What is the Year-over-Year (YoY) and Month-over-Month (MoM) growth trajectory? What is the 4-week moving average per store?

> *Please view [`sql/business_queries.sql`](sql/business_queries.sql) and [`sql/advanced_queries.sql`](sql/advanced_queries.sql) for the exact code implementations.*

---

## 💡 Strategic Business Insights
Data without interpretation is just noise. Below is a sample of the strategic insights derived from the SQL queries. 

*   **Localized Inventory Routing:** Holiday weeks show massive revenue spikes, but the lift is hyper-concentrated in specific stores. Supply chain algorithms must dynamically route inventory to high-lift stores 2 weeks prior to Thanksgiving/Christmas to prevent stockouts.
*   **Recession-Resistant Assortment:** Stores operating in environments with >8.5% unemployment still maintain high volume, suggesting consumers pivot to essential, low-margin goods (Everyday Low Price strategy). Discretionary inventory (electronics/apparel) should be minimized in these locations to prevent markdown losses.
*   **Rolling Forecasts:** Static yearly budgets fail in volatile macroeconomic environments. The 4-week moving average views created in SQL should be fed directly into BI tools to create dynamic, rolling quarterly forecasts.

> *For a full breakdown of 20+ insights, view the [`insights.md`](insights.md) document.*

---

## 📂 Repository Structure
```text
Walmart-SQL-Analytics/
│
├── data/                   # Raw CSV dataset (Walmart_Sales.csv)
│
├── sql/
│   ├── schema.sql           # DDL for Database, Tables, Indexes, and FKs
│   ├── import_data.sql      # LOAD DATA INFILE and Dimension population
│   ├── cleaning.sql         # Data validation, duplicate checks, outlier detection
│   ├── business_queries.sql # Intermediate queries (Store, Macro, Holiday Analysis)
│   ├── advanced_queries.sql # Advanced queries (CTEs, Window Functions, Moving Averages)
│   └── views.sql            # Standardized Views for BI Dashboard integration
│
├── README.md               # Project documentation
│
└── insights.md             # Translation of SQL output into C-suite recommendations
```

---

## 🚀 Future Improvements
- **Stored Procedures:** Wrap the daily data ingestion and cleaning process into an automated `STORED PROCEDURE` that can be scheduled via an event scheduler.
- **Data Pipeline Integration:** Connect this MySQL database to an Apache Airflow DAG to simulate a real-time ETL pipeline.
- **Dashboarding:** Connect Tableau or PowerBI directly to the `vw_monthly_store_performance` and `vw_macro_risk_profile` views to visualize the moving averages and risk tiers.
