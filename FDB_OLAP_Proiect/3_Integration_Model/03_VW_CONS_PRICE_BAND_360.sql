-- =========================================================
-- VW_CONS_PRICE_BAND_360
-- =========================================================

CREATE OR REPLACE VIEW VW_CONS_PRICE_BAND_360 AS
WITH ds1 AS (
    SELECT
        CASE
            WHEN unit_price < 25 THEN '0-25'
            WHEN unit_price < 50 THEN '25-50'
            WHEN unit_price < 100 THEN '50-100'
            WHEN unit_price < 250 THEN '100-250'
            ELSE '250+'
        END AS band_name,
        COUNT(*) AS sales_rows,
        SUM(line_amount) AS total_sales_amount,
        AVG(unit_price) AS avg_unit_price
    FROM AM_DS1_RETAIL_PGRST_V
    GROUP BY
        CASE
            WHEN unit_price < 25 THEN '0-25'
            WHEN unit_price < 50 THEN '25-50'
            WHEN unit_price < 100 THEN '50-100'
            WHEN unit_price < 250 THEN '100-250'
            ELSE '250+'
        END
),
ds2 AS (
    SELECT
        CASE
            WHEN order_value_usd < 25 THEN '0-25'
            WHEN order_value_usd < 50 THEN '25-50'
            WHEN order_value_usd < 100 THEN '50-100'
            WHEN order_value_usd < 250 THEN '100-250'
            ELSE '250+'
        END AS band_name,
        COUNT(*) AS behavior_rows,
        AVG(order_value_usd) AS avg_order_value,
        AVG(customer_rating) AS avg_customer_rating
    FROM AM_DS2_CUSTOMER_BEHAVIOR_V
    GROUP BY
        CASE
            WHEN order_value_usd < 25 THEN '0-25'
            WHEN order_value_usd < 50 THEN '25-50'
            WHEN order_value_usd < 100 THEN '50-100'
            WHEN order_value_usd < 250 THEN '100-250'
            ELSE '250+'
        END
),
ds3 AS (
    SELECT
        CASE
            WHEN price_usd < 25 THEN '0-25'
            WHEN price_usd < 50 THEN '25-50'
            WHEN price_usd < 100 THEN '50-100'
            WHEN price_usd < 250 THEN '100-250'
            ELSE '250+'
        END AS band_name,
        COUNT(*) AS product_rows,
        AVG(price_usd) AS avg_product_price,
        AVG(rating_stars) AS avg_rating_stars,
        SUM(review_count) AS total_review_count
    FROM AM_DS3_AMAZON_PRODUCTS_V
    WHERE price_usd IS NOT NULL
    GROUP BY
        CASE
            WHEN price_usd < 25 THEN '0-25'
            WHEN price_usd < 50 THEN '25-50'
            WHEN price_usd < 100 THEN '50-100'
            WHEN price_usd < 250 THEN '100-250'
            ELSE '250+'
        END
)
SELECT
    d.band_id,
    d.band_name,
    ds1.sales_rows,
    ds1.total_sales_amount,
    ds1.avg_unit_price,
    ds2.behavior_rows,
    ds2.avg_order_value,
    ds2.avg_customer_rating,
    ds3.product_rows,
    ds3.avg_product_price,
    ds3.avg_rating_stars,
    ds3.total_review_count
FROM DIM_PRICE_BAND d
LEFT JOIN ds1 ON d.band_name = ds1.band_name
LEFT JOIN ds2 ON d.band_name = ds2.band_name
LEFT JOIN ds3 ON d.band_name = ds3.band_name;
