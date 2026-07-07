-- ==============================================================================
-- STEP 3: DATA IMPORTING & POPULATING TABLES
-- ==============================================================================
-- Note: Update the path 'E:/DA/walmart sales sql/data/Walmart_Sales.csv'
-- to your absolute path and ensure MySQL has `local_infile` enabled.
-- ==============================================================================

USE walmart_sales;

-- 1. Load raw data into the staging table
-- Note: Due to strict --secure-file-priv settings in MySQL,
-- the raw CSV data has been converted directly into SQL INSERT statements.
-- PLEASE RUN `sql/insert_staging.sql` FIRST to populate `staging_sales`!

-- 2. Populate dim_stores
-- Using INSERT IGNORE to prevent duplicate errors
INSERT IGNORE INTO dim_stores (store_id)
SELECT DISTINCT Store 
FROM staging_sales;

-- 3. Populate dim_calendar
-- Converting 'DD-MM-YYYY' string to proper DATE format
-- Extracting time intelligence features for advanced querying
INSERT IGNORE INTO dim_calendar (cal_date, holiday_flag, week_no, month_no, year_no, quarter_no, day_name)
SELECT DISTINCT 
    STR_TO_DATE(Date, '%d-%m-%Y') AS cal_date,
    Holiday_Flag,
    WEEK(STR_TO_DATE(Date, '%d-%m-%Y')) AS week_no,
    MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS month_no,
    YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS year_no,
    QUARTER(STR_TO_DATE(Date, '%d-%m-%Y')) AS quarter_no,
    DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y')) AS day_nameran 
FROM staging_sales;

-- 4. Populate fact_sales
-- Linking the dimensions using Store and formatted Date
INSERT INTO fact_sales (store_id, cal_date, weekly_sales, temperature, fuel_price, cpi, unemployment)
SELECT 
    Store,
    STR_TO_DATE(Date, '%d-%m-%Y'),
    Weekly_Sales,
    Temperature,
    Fuel_Price,
    CPI,
    Unemployment
FROM staging_sales;

-- Optional: You can DROP the staging table after a successful load to save space
-- DROP TABLE staging_sales;
