-- ==============================================================================
-- STEP 7: VIEWS FOR REPORTING & BI INTEGRATION
-- ==============================================================================
-- Project: Walmart Retail Sales SQL Analytics
-- Description: Creates standardized views to be queried by BI tools like Tableau/PowerBI.
-- ==============================================================================

USE walmart_sales;

-- 35. View: Monthly Store Performance
-- Useful for high-level dashboards showing MoM trends.
CREATE OR REPLACE VIEW vw_monthly_store_performance AS
SELECT 
    f.store_id, 
    c.year_no, 
    c.month_no, 
    SUM(f.weekly_sales) AS total_sales,
    ROUND(AVG(f.temperature), 2) AS avg_temp,
    ROUND(AVG(f.unemployment), 2) AS avg_unemployment,
    ROUND(AVG(f.cpi), 2) AS avg_cpi
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY f.store_id, c.year_no, c.month_no;

-- 36. View: Holiday Impact Summary
-- Quickly analyze which years had the best holiday sales.
CREATE OR REPLACE VIEW vw_holiday_sales_summary AS
SELECT 
    c.year_no,
    SUM(CASE WHEN c.holiday_flag = 1 THEN f.weekly_sales ELSE 0 END) AS holiday_sales,
    SUM(CASE WHEN c.holiday_flag = 0 THEN f.weekly_sales ELSE 0 END) AS non_holiday_sales,
    ROUND(
        SUM(CASE WHEN c.holiday_flag = 1 THEN f.weekly_sales ELSE 0 END) / NULLIF(SUM(f.weekly_sales), 0) * 100, 2
    ) AS holiday_sales_pct
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.year_no;

-- 37. View: Macroeconomic Store Risk Profile
-- Highlights stores operating in tough macroeconomic conditions (High Unemployment & CPI).
CREATE OR REPLACE VIEW vw_macro_risk_profile AS
SELECT 
    store_id,
    ROUND(AVG(unemployment), 2) AS historical_avg_unemployment,
    ROUND(MAX(cpi), 2) AS peak_cpi,
    SUM(weekly_sales) AS lifetime_sales,
    CASE 
        WHEN AVG(unemployment) > 8.5 AND MAX(cpi) > 210 THEN 'High Risk'
        WHEN AVG(unemployment) BETWEEN 6.5 AND 8.5 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_tier
FROM fact_sales
GROUP BY store_id;

-- 38. View: Store Weekly Moving Average (4-Week)
-- Pre-calculated moving average for trend line charts.
CREATE OR REPLACE VIEW vw_store_moving_avg AS
SELECT 
    store_id, 
    cal_date, 
    weekly_sales,
    AVG(weekly_sales) OVER (PARTITION BY store_id ORDER BY cal_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_avg_4_weeks
FROM fact_sales;

-- 39. View: Year-over-Year Growth by Store
CREATE OR REPLACE VIEW vw_store_yoy_growth AS
WITH YearlySales AS (
    SELECT f.store_id, c.year_no, SUM(f.weekly_sales) AS total_sales
    FROM fact_sales f
    JOIN dim_calendar c ON f.cal_date = c.cal_date
    GROUP BY f.store_id, c.year_no
)
SELECT 
    store_id, 
    year_no, 
    total_sales,
    LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year_no) AS prev_year_sales,
    ROUND(((total_sales - LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year_no)) / 
            NULLIF(LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year_no), 0)) * 100, 2) AS yoy_growth_pct
FROM YearlySales;

-- 40. View: Comprehensive Weekly Fact View
-- A denormalized view linking everything for a BI tool that prefers a flat structure.
CREATE OR REPLACE VIEW vw_flat_sales_data AS
SELECT 
    f.sale_id,
    s.store_id,
    c.cal_date,
    c.week_no,
    c.month_no,
    c.quarter_no,
    c.year_no,
    c.day_name,
    c.holiday_flag,
    f.weekly_sales,
    f.temperature,
    f.fuel_price,
    f.cpi,
    f.unemployment
FROM fact_sales f
JOIN dim_stores s ON f.store_id = s.store_id
JOIN dim_calendar c ON f.cal_date = c.cal_date;
