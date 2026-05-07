--------------------------------------------------------------------------------
-- SparkSQL_OLAP.sql
-- Integration and Analytical Model for DSA / Java4DI Architecture
--
-- Source SparkSQL access views:
-- 1. retail_transactions_view   -- DS1 PostgreSQL through DSA-SQL-JDBCService
-- 2. customer_behavior_view     -- DS2 CSV through DSA-DOC-CSVService
-- 3. amazon_products_view       -- DS3 MongoDB through DSA-NoSQL-MongoDBService
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- CLEAN-UP
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS dsa_dim_price_band;
DROP VIEW IF EXISTS dsa_dim_time_ds1_v;
DROP VIEW IF EXISTS dsa_fact_retail_sales_v;
DROP VIEW IF EXISTS dsa_behavior_by_price_band_v;
DROP VIEW IF EXISTS dsa_amazon_by_price_band_v;
DROP VIEW IF EXISTS dsa_price_band_360_v;
DROP VIEW IF EXISTS dsa_sales_rollup_time_band_v;
DROP VIEW IF EXISTS dsa_sales_cube_country_band_v;
DROP VIEW IF EXISTS dsa_customer_behavior_segments_v;
DROP VIEW IF EXISTS dsa_amazon_category_stats_v;

--------------------------------------------------------------------------------
-- 1. DIMENSION: PRICE BAND
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_dim_price_band AS
SELECT stack(
               5,
               1, '0-25',    CAST(0 AS DECIMAL(12,2)),   CAST(25 AS DECIMAL(12,2)),
               2, '25-50',   CAST(25 AS DECIMAL(12,2)),  CAST(50 AS DECIMAL(12,2)),
               3, '50-100',  CAST(50 AS DECIMAL(12,2)),  CAST(100 AS DECIMAL(12,2)),
               4, '100-250', CAST(100 AS DECIMAL(12,2)), CAST(250 AS DECIMAL(12,2)),
               5, '250+',    CAST(250 AS DECIMAL(12,2)), CAST(999999 AS DECIMAL(12,2))
       ) AS (band_id, band_name, min_value, max_value);

--------------------------------------------------------------------------------
-- 2. DIMENSION: TIME FROM DS1 RETAIL TRANSACTIONS
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_dim_time_ds1_v AS
SELECT DISTINCT
    CAST(invoice_date AS TIMESTAMP) AS invoice_timestamp,
    YEAR(CAST(invoice_date AS TIMESTAMP)) AS invoice_year,
    MONTH(CAST(invoice_date AS TIMESTAMP)) AS invoice_month,
    DAY(CAST(invoice_date AS TIMESTAMP)) AS invoice_day,
    HOUR(CAST(invoice_date AS TIMESTAMP)) AS invoice_hour
FROM retail_transactions_view
WHERE invoice_date IS NOT NULL;

--------------------------------------------------------------------------------
-- 3. FACT VIEW: RETAIL SALES FROM DS1
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_fact_retail_sales_v AS
SELECT
    r.row_id,
    r.invoice_no,
    r.stock_code,
    r.description,
    r.quantity,
    CAST(r.invoice_date AS TIMESTAMP) AS invoice_timestamp,
    YEAR(CAST(r.invoice_date AS TIMESTAMP)) AS invoice_year,
    MONTH(CAST(r.invoice_date AS TIMESTAMP)) AS invoice_month,
    r.unit_price,
    CAST(r.quantity * r.unit_price AS DECIMAL(14,2)) AS sales_amount,
    r.customer_id,
    r.country,
    r.is_cancellation,
    r.is_return,
    b.band_id,
    b.band_name
FROM retail_transactions_view r
    LEFT JOIN dsa_dim_price_band b
ON r.unit_price >= b.min_value
    AND r.unit_price < b.max_value
WHERE r.unit_price IS NOT NULL
  AND r.quantity IS NOT NULL;

--------------------------------------------------------------------------------
-- 4. DS2 AGGREGATION: CUSTOMER BEHAVIOR BY PRICE BAND
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_behavior_by_price_band_v AS
SELECT
    b.band_id,
    b.band_name,
    COUNT(*) AS behavior_rows,
    AVG(cb.age) AS avg_customer_age,
    AVG(cb.purchase_amount) AS avg_purchase_amount,
    AVG(cb.delivery_time_days) AS avg_delivery_time_days,
    AVG(cb.customer_rating) AS avg_customer_rating,
    SUM(CASE WHEN cb.return_status = true THEN 1 ELSE 0 END) AS returned_orders
FROM customer_behavior_view cb
         LEFT JOIN dsa_dim_price_band b
                   ON cb.purchase_amount >= b.min_value
                       AND cb.purchase_amount < b.max_value
GROUP BY b.band_id, b.band_name;

--------------------------------------------------------------------------------
-- 5. DS3 AGGREGATION: AMAZON PRODUCTS BY PRICE BAND
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_amazon_by_price_band_v AS
SELECT
    b.band_id,
    b.band_name,
    COUNT(*) AS product_rows,
    AVG(ap.price_usd) AS avg_product_price,
    AVG(ap.rating_stars) AS avg_rating_stars,
    AVG(ap.rating_count) AS avg_rating_count,
    AVG(ap.review_count) AS avg_review_count
FROM amazon_products_view ap
         LEFT JOIN dsa_dim_price_band b
                   ON ap.price_usd >= b.min_value
                       AND ap.price_usd < b.max_value
GROUP BY b.band_id, b.band_name;

--------------------------------------------------------------------------------
-- 6. INTEGRATED 360 VIEW BY PRICE BAND
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_price_band_360_v AS
SELECT
    pb.band_id,
    pb.band_name,

    COALESCE(s.sales_rows, 0) AS sales_rows,
    COALESCE(s.total_sales_amount, 0) AS total_sales_amount,
    s.avg_unit_price,

    COALESCE(b.behavior_rows, 0) AS behavior_rows,
    b.avg_customer_age,
    b.avg_purchase_amount,
    b.avg_delivery_time_days,
    b.avg_customer_rating,
    COALESCE(b.returned_orders, 0) AS returned_orders,

    COALESCE(a.product_rows, 0) AS product_rows,
    a.avg_product_price,
    a.avg_rating_stars,
    a.avg_rating_count,
    a.avg_review_count

FROM dsa_dim_price_band pb

         LEFT JOIN (
    SELECT
        band_id,
        band_name,
        COUNT(*) AS sales_rows,
        SUM(sales_amount) AS total_sales_amount,
        AVG(unit_price) AS avg_unit_price
    FROM dsa_fact_retail_sales_v
    GROUP BY band_id, band_name
) s
                   ON pb.band_id = s.band_id

         LEFT JOIN dsa_behavior_by_price_band_v b
                   ON pb.band_id = b.band_id

         LEFT JOIN dsa_amazon_by_price_band_v a
                   ON pb.band_id = a.band_id;

--------------------------------------------------------------------------------
-- 7. ANALYTICAL VIEW: SALES ROLLUP BY TIME AND PRICE BAND
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_sales_rollup_time_band_v AS
SELECT
    invoice_year,
    invoice_month,
    band_name,
    COUNT(*) AS sales_rows,
    SUM(sales_amount) AS total_sales_amount,
    AVG(unit_price) AS avg_unit_price
FROM dsa_fact_retail_sales_v
GROUP BY ROLLUP(invoice_year, invoice_month, band_name);

--------------------------------------------------------------------------------
-- 8. ANALYTICAL VIEW: SALES CUBE BY COUNTRY AND PRICE BAND
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_sales_cube_country_band_v AS
SELECT
    country,
    band_name,
    COUNT(*) AS sales_rows,
    SUM(sales_amount) AS total_sales_amount,
    AVG(unit_price) AS avg_unit_price
FROM dsa_fact_retail_sales_v
GROUP BY CUBE(country, band_name);

--------------------------------------------------------------------------------
-- 9. ANALYTICAL VIEW: CUSTOMER BEHAVIOR SEGMENTS
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_customer_behavior_segments_v AS
SELECT
    gender,
    product_category,
    payment_method,
    COUNT(*) AS order_rows,
    AVG(age) AS avg_age,
    AVG(purchase_amount) AS avg_purchase_amount,
    AVG(delivery_time_days) AS avg_delivery_time_days,
    AVG(customer_rating) AS avg_customer_rating,
    SUM(CASE WHEN return_status = true THEN 1 ELSE 0 END) AS returned_orders
FROM customer_behavior_view
GROUP BY gender, product_category, payment_method;

--------------------------------------------------------------------------------
-- 10. ANALYTICAL VIEW: AMAZON CATEGORY STATISTICS
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW dsa_amazon_category_stats_v AS
SELECT
    category_main,
    category_sub,
    COUNT(*) AS product_rows,
    AVG(price_usd) AS avg_price_usd,
    AVG(rating_stars) AS avg_rating_stars,
    AVG(rating_count) AS avg_rating_count,
    AVG(review_count) AS avg_review_count
FROM amazon_products_view
GROUP BY category_main, category_sub;

--------------------------------------------------------------------------------
-- VALIDATION QUERIES
--------------------------------------------------------------------------------

SELECT *
FROM dsa_price_band_360_v
ORDER BY band_id;

SELECT *
FROM dsa_sales_rollup_time_band_v
         LIMIT 20;

SELECT *
FROM dsa_sales_cube_country_band_v
         LIMIT 20;

SELECT *
FROM dsa_customer_behavior_segments_v
         LIMIT 20;

SELECT *
FROM dsa_amazon_category_stats_v
         LIMIT 20;