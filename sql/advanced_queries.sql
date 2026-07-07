-- ==============================================================================
-- STEP 6: ADVANCED SQL QUERIES
-- ==============================================================================
-- Project: Walmart Retail Sales SQL Analytics
-- Description: Utilizes Window Functions, CTEs, and Complex Aggregations.
-- ==============================================================================

USE walmart_sales;

-- 25. Store Sales Ranking (Using RANK() and DENSE_RANK())
-- Ranking stores based on their all-time total sales.
SELECT store_id, 
       SUM(weekly_sales) AS total_sales,
       RANK() OVER (ORDER BY SUM(weekly_sales) DESC) AS sales_rank,
       DENSE_RANK() OVER (ORDER BY SUM(weekly_sales) DESC) AS sales_dense_rank
FROM fact_sales
GROUP BY store_id;

-- 26. Store Month-over-Month (MoM) Growth (Using LAG())
-- Comparing a store's monthly sales to its previous month.
WITH MonthlySales AS (
    SELECT f.store_id, c.year_no, c.month_no, SUM(f.weekly_sales) AS total_sales
    FROM fact_sales f
    JOIN dim_calendar c ON f.cal_date = c.cal_date
    GROUP BY f.store_id, c.year_no, c.month_no
)
SELECT store_id, year_no, month_no, total_sales,
       LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year_no, month_no) AS prev_month_sales,
       ROUND(((total_sales - LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year_no, month_no)) / 
               LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year_no, month_no)) * 100, 2) AS mom_growth_pct
FROM MonthlySales;

-- 27. Running Total of Sales for a specific store (Using SUM() OVER)
-- Let's look at Store 1's cumulative sales over time.
SELECT store_id, cal_date, weekly_sales,
       SUM(weekly_sales) OVER (PARTITION BY store_id ORDER BY cal_date) AS running_total_sales
FROM fact_sales
WHERE store_id = 1;

-- 28. 4-Week Moving Average of Sales per Store (Using Window Functions)
SELECT store_id, cal_date, weekly_sales,
       AVG(weekly_sales) OVER (
           PARTITION BY store_id 
           ORDER BY cal_date 
           ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
       ) AS four_week_moving_avg
FROM fact_sales;

-- 29. Top 2 Best Performing Weeks per Store (Using ROW_NUMBER())
WITH RankedWeeks AS (
    SELECT store_id, cal_date, weekly_sales,
           ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY weekly_sales DESC) AS rn
    FROM fact_sales
)
SELECT store_id, cal_date, weekly_sales
FROM RankedWeeks
WHERE rn <= 2;

-- 30. Predicting next week's sales naive forecast (Using LEAD())
SELECT store_id, cal_date, weekly_sales,
       LEAD(weekly_sales) OVER (PARTITION BY store_id ORDER BY cal_date) AS next_week_actual,
       (weekly_sales - LEAD(weekly_sales) OVER (PARTITION BY store_id ORDER BY cal_date)) AS difference
FROM fact_sales;

-- 31. Correlated Subquery: Stores whose average sales are higher than the overall average sales
SELECT store_id, AVG(weekly_sales) AS avg_store_sales
FROM fact_sales f1
GROUP BY store_id
HAVING AVG(weekly_sales) > (
    SELECT AVG(weekly_sales) 
    FROM fact_sales
);

-- 32. Complex CTE: Identifying "High Risk" weeks
-- High Risk: High unemployment (>8%) AND High CPI (>200) AND Low Sales (Bottom 25th percentile)
WITH SalesPercentile AS (
    SELECT weekly_sales,
           PERCENT_RANK() OVER (ORDER BY weekly_sales) AS pct_rank
    FROM fact_sales
)
SELECT f.store_id, f.cal_date, f.weekly_sales, f.unemployment, f.cpi
FROM fact_sales f
WHERE f.unemployment > 8.0 
  AND f.cpi > 200
  AND f.weekly_sales <= (
      SELECT MAX(weekly_sales) 
      FROM SalesPercentile 
      WHERE pct_rank <= 0.25
  );

-- 33. Which Quarter generated the most revenue across all years using UNION?
-- Demonstrating UNION usage to combine separate Q1, Q2, Q3, Q4 aggregations (though GROUP BY is better).
SELECT 'Q1' AS Quarter, SUM(f.weekly_sales) AS Total_Sales FROM fact_sales f JOIN dim_calendar c ON f.cal_date = c.cal_date WHERE c.quarter_no = 1
UNION
SELECT 'Q2' AS Quarter, SUM(f.weekly_sales) AS Total_Sales FROM fact_sales f JOIN dim_calendar c ON f.cal_date = c.cal_date WHERE c.quarter_no = 2
UNION
SELECT 'Q3' AS Quarter, SUM(f.weekly_sales) AS Total_Sales FROM fact_sales f JOIN dim_calendar c ON f.cal_date = c.cal_date WHERE c.quarter_no = 3
UNION
SELECT 'Q4' AS Quarter, SUM(f.weekly_sales) AS Total_Sales FROM fact_sales f JOIN dim_calendar c ON f.cal_date = c.cal_date WHERE c.quarter_no = 4
ORDER BY Total_Sales DESC;

-- 34. Cumulative distribution of sales (CUME_DIST)
SELECT store_id, cal_date, weekly_sales,
       ROUND(CUME_DIST() OVER (PARTITION BY store_id ORDER BY weekly_sales), 2) AS cumulative_distribution
FROM fact_sales;
