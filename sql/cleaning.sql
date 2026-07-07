-- ==============================================================================
-- STEP 4: DATA CLEANING & VALIDATION
-- ==============================================================================
-- Project: Walmart Retail Sales SQL Analytics
-- Description: Identifying and handling anomalies, invalid data, or outliers.
-- ==============================================================================

USE walmart_sales;

-- 1. Check for missing values in critical columns
-- Though our EDA showed 0 missing values, this is a standard SQL check.
SELECT *
FROM fact_sales
WHERE weekly_sales IS NULL 
   OR store_id IS NULL 
   OR cal_date IS NULL;

-- 2. Validate Date ranges (e.g., ensuring no future dates or extreme past dates)
SELECT MIN(cal_date) AS min_date, MAX(cal_date) AS max_date 
FROM dim_calendar;

-- 3. Identify and handle negative or zero weekly sales
-- Sales should typically be positive. Let's see if any stores recorded a loss/error.
SELECT count(*) AS negative_sales_count
FROM fact_sales
WHERE weekly_sales <= 0;

-- 4. Delete negative sales (If instructed by business rules)
-- In a real scenario, we might keep them for return analysis, but here we assume errors.
/*
DELETE FROM fact_sales 
WHERE weekly_sales <= 0;
*/

-- 5. Detect outliers in Macroeconomic indicators (e.g., Unemployment rate > 15%)
SELECT store_id, cal_date, unemployment
FROM fact_sales
WHERE unemployment > 14;

-- 6. Check for duplicate records in fact table
SELECT store_id, cal_date, COUNT(*)
FROM fact_sales
GROUP BY store_id, cal_date
HAVING COUNT(*) > 1;

-- No duplicates found in EDA, but if there were, we'd remove them via a CTE.
