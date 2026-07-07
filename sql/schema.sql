-- ==============================================================================
-- STEP 2: DATABASE DESIGN & SCHEMA CREATION
-- ==============================================================================
-- Project: Walmart Retail Sales SQL Analytics
-- Description: Creates the normalized database schema (Star Schema).
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS walmart_sales;
USE walmart_sales;

-- ------------------------------------------------------------------------------
-- 1. STAGING TABLE
-- Used for initial bulk load of the raw CSV file.
-- Dates are stored as VARCHAR initially to handle the 'DD-MM-YYYY' format gracefully.
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS staging_sales;
CREATE TABLE staging_sales (
    Store INT,
    Date VARCHAR(20),
    Weekly_Sales DECIMAL(15, 2),
    Holiday_Flag INT,
    Temperature DECIMAL(6, 2),
    Fuel_Price DECIMAL(6, 3),
    CPI DECIMAL(12, 7),
    Unemployment DECIMAL(8, 3)
);

-- ------------------------------------------------------------------------------
-- 2. DIMENSION TABLES
-- Normalizing the single dataset into a Star Schema.
-- ------------------------------------------------------------------------------

-- Dimension Table: dim_stores
-- Represents unique stores.
DROP TABLE IF EXISTS dim_stores;
CREATE TABLE dim_stores (
    store_id INT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Table: dim_calendar
-- Represents dates, derived from the raw data.
-- Adding calculated time hierarchies (week, month, year, quarter) for easier grouping.
DROP TABLE IF EXISTS dim_calendar;
CREATE TABLE dim_calendar (
    cal_date DATE PRIMARY KEY,
    holiday_flag BOOLEAN,
    week_no INT,
    month_no INT,
    year_no INT,
    quarter_no INT,
    day_name VARCHAR(15)
);

-- ------------------------------------------------------------------------------
-- 3. FACT TABLE
-- ------------------------------------------------------------------------------

-- Fact Table: fact_sales
-- Stores the quantitative weekly sales data and macroeconomic indicators.
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    cal_date DATE NOT NULL,
    weekly_sales DECIMAL(15, 2) NOT NULL,
    temperature DECIMAL(6, 2),
    fuel_price DECIMAL(6, 3),
    cpi DECIMAL(12, 7),
    unemployment DECIMAL(8, 3),
    
    -- Foreign Keys defining relationships
    CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES dim_stores(store_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_date FOREIGN KEY (cal_date) REFERENCES dim_calendar(cal_date)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------------------------
-- 4. INDEXES FOR OPTIMIZATION
-- ------------------------------------------------------------------------------
-- Indexes to improve JOIN performance and query filtering.
CREATE INDEX idx_fact_store ON fact_sales(store_id);
CREATE INDEX idx_fact_date ON fact_sales(cal_date);
