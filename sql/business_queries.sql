-- ==============================================================================
-- STEP 5: BUSINESS QUERIES (Intermediate & Analytical)
-- ==============================================================================
-- Project: Walmart Retail Sales SQL Analytics
-- Description: Core business questions answering Store, Time, and Macro trends.
-- ==============================================================================

USE walmart_sales;

-- ------------------------------------------------------------------------------
-- A. STORE PERFORMANCE ANALYSIS
-- ------------------------------------------------------------------------------

-- 1. Total Sales by Store (All Time)
SELECT store_id, SUM(weekly_sales) AS total_sales
FROM fact_sales
GROUP BY store_id
ORDER BY total_sales DESC;

-- 2. Average Weekly Sales by Store
SELECT store_id, ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM fact_sales
GROUP BY store_id
ORDER BY avg_weekly_sales DESC;

-- 3. Top 5 Highest Grossing Stores
SELECT store_id, SUM(weekly_sales) AS total_sales
FROM fact_sales
GROUP BY store_id
ORDER BY total_sales DESC
LIMIT 5;

-- 4. Bottom 5 Lowest Grossing Stores
SELECT store_id, SUM(weekly_sales) AS total_sales
FROM fact_sales
GROUP BY store_id
ORDER BY total_sales ASC
LIMIT 5;

-- 5. Store Sales Contribution Percentage (Subquery)
SELECT store_id, 
       SUM(weekly_sales) AS total_sales,
       ROUND((SUM(weekly_sales) / (SELECT SUM(weekly_sales) FROM fact_sales)) * 100, 2) AS contribution_pct
FROM fact_sales
GROUP BY store_id
ORDER BY contribution_pct DESC;

-- 6. Which stores had a week with sales exceeding $2.5 million?
SELECT DISTINCT store_id
FROM fact_sales
WHERE weekly_sales > 2500000;

-- 7. Count of weeks each store exceeded $2 million
SELECT store_id, COUNT(*) AS weeks_above_2M
FROM fact_sales
WHERE weekly_sales > 2000000
GROUP BY store_id
ORDER BY weeks_above_2M DESC;

-- 8. Stores where average unemployment was higher than 9% but still in top 10 sales
SELECT f.store_id, AVG(f.unemployment) AS avg_unemployment, SUM(f.weekly_sales) AS total_sales
FROM fact_sales f
GROUP BY f.store_id
HAVING AVG(f.unemployment) > 9.0
ORDER BY total_sales DESC
LIMIT 10;

-- 9. Variance between Max and Min weekly sales per store (Consistency check)
SELECT store_id, 
       MAX(weekly_sales) AS max_sales, 
       MIN(weekly_sales) AS min_sales,
       (MAX(weekly_sales) - MIN(weekly_sales)) AS sales_variance
FROM fact_sales
GROUP BY store_id
ORDER BY sales_variance DESC;

-- ------------------------------------------------------------------------------
-- B. HOLIDAY IMPACT ANALYSIS
-- ------------------------------------------------------------------------------

-- 10. Total Sales: Holiday vs Non-Holiday Weeks
SELECT c.holiday_flag, SUM(f.weekly_sales) AS total_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.holiday_flag;

-- 11. Average Weekly Sales: Holiday vs Non-Holiday
SELECT c.holiday_flag, ROUND(AVG(f.weekly_sales), 2) AS avg_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.holiday_flag;

-- 12. Percentage difference in Average Sales (Holiday vs Non-Holiday)
SELECT 
    (SELECT AVG(weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.holiday_flag = 1) AS avg_holiday_sales,
    (SELECT AVG(weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.holiday_flag = 0) AS avg_non_holiday_sales,
    ROUND(((SELECT AVG(weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.holiday_flag = 1) / 
           (SELECT AVG(weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.holiday_flag = 0) - 1) * 100, 2) AS pct_increase;

-- 13. Which store benefits the MOST from Holidays?
SELECT f.store_id, 
       AVG(CASE WHEN c.holiday_flag = 1 THEN f.weekly_sales END) AS avg_holiday,
       AVG(CASE WHEN c.holiday_flag = 0 THEN f.weekly_sales END) AS avg_non_holiday,
       (AVG(CASE WHEN c.holiday_flag = 1 THEN f.weekly_sales END) - AVG(CASE WHEN c.holiday_flag = 0 THEN f.weekly_sales END)) AS holiday_lift
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY f.store_id
ORDER BY holiday_lift DESC
LIMIT 5;

-- 14. Which holidays (months) see the highest spikes? (Assuming Dec/Nov are holidays)
SELECT c.month_no, SUM(f.weekly_sales) AS holiday_month_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
WHERE c.holiday_flag = 1
GROUP BY c.month_no
ORDER BY holiday_month_sales DESC;

-- ------------------------------------------------------------------------------
-- C. MACROECONOMIC & WEATHER ANALYSIS
-- ------------------------------------------------------------------------------

-- 15. Average Fuel Price and CPI by Year
SELECT c.year_no, ROUND(AVG(f.fuel_price), 2) AS avg_fuel_price, ROUND(AVG(f.cpi), 2) AS avg_cpi
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.year_no
ORDER BY c.year_no;

-- 16. Do higher fuel prices correlate with lower sales? (Bucketing Fuel Prices)
SELECT 
    CASE 
        WHEN fuel_price < 3.0 THEN 'Low (< $3.0)'
        WHEN fuel_price BETWEEN 3.0 AND 3.5 THEN 'Medium ($3.0 - $3.5)'
        ELSE 'High (> $3.5)'
    END AS fuel_price_tier,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM fact_sales
GROUP BY fuel_price_tier
ORDER BY avg_weekly_sales DESC;

-- 17. Impact of Unemployment on Sales (Bucketing Unemployment)
SELECT 
    CASE 
        WHEN unemployment < 6.0 THEN 'Low (< 6%)'
        WHEN unemployment BETWEEN 6.0 AND 9.0 THEN 'Medium (6% - 9%)'
        ELSE 'High (> 9%)'
    END AS unemployment_tier,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM fact_sales
GROUP BY unemployment_tier
ORDER BY avg_weekly_sales DESC;

-- 18. Effect of Extreme Temperatures on Sales
SELECT 
    CASE 
        WHEN temperature < 32 THEN 'Freezing (< 32F)'
        WHEN temperature BETWEEN 32 AND 80 THEN 'Mild (32F - 80F)'
        ELSE 'Hot (> 80F)'
    END AS temp_tier,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM fact_sales
GROUP BY temp_tier
ORDER BY avg_weekly_sales DESC;

-- 19. Identify weeks where CPI was at its peak for each store
SELECT store_id, cal_date, cpi, weekly_sales
FROM fact_sales f1
WHERE cpi = (SELECT MAX(cpi) FROM fact_sales f2 WHERE f1.store_id = f2.store_id);

-- ------------------------------------------------------------------------------
-- D. TIME / TREND ANALYSIS
-- ------------------------------------------------------------------------------

-- 20. Total Revenue by Year
SELECT c.year_no, SUM(f.weekly_sales) AS yearly_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.year_no
ORDER BY c.year_no;

-- 21. Total Revenue by Quarter
SELECT c.year_no, c.quarter_no, SUM(f.weekly_sales) AS quarterly_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.year_no, c.quarter_no
ORDER BY c.year_no, c.quarter_no;

-- 22. Best Selling Month overall
SELECT c.month_no, SUM(f.weekly_sales) AS total_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.month_no
ORDER BY total_sales DESC;

-- 23. Average weekly sales by Day of Week (Sanity Check - they should all be Fridays typically)
SELECT c.day_name, COUNT(*) AS count_of_weeks, SUM(f.weekly_sales) AS total_sales
FROM fact_sales f
JOIN dim_calendar c ON f.cal_date = c.cal_date
GROUP BY c.day_name;

-- 24. Year-over-Year Growth (YoY) - 2010 vs 2011
SELECT 
    (SELECT SUM(f.weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.year_no = 2011) AS sales_2011,
    (SELECT SUM(f.weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.year_no = 2010) AS sales_2010,
    ROUND((
        (SELECT SUM(f.weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.year_no = 2011) - 
        (SELECT SUM(f.weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.year_no = 2010)
    ) / (SELECT SUM(f.weekly_sales) FROM fact_sales f JOIN dim_calendar c ON f.cal_date=c.cal_date WHERE c.year_no = 2010) * 100, 2) AS yoy_growth_pct;
