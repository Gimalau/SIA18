-- =========================================================
-- FACT_PRICE_BAND_360_V
-- =========================================================

CREATE OR REPLACE VIEW FACT_PRICE_BAND_360_V AS
SELECT
    band_id,
    band_name,
    NVL(sales_rows, 0) AS sales_rows,
    NVL(total_sales_amount, 0) AS total_sales_amount,
    NVL(avg_unit_price, 0) AS avg_unit_price,
    NVL(behavior_rows, 0) AS behavior_rows,
    NVL(avg_order_value, 0) AS avg_order_value,
    NVL(avg_customer_rating, 0) AS avg_customer_rating,
    NVL(product_rows, 0) AS product_rows,
    NVL(avg_product_price, 0) AS avg_product_price,
    NVL(avg_rating_stars, 0) AS avg_rating_stars,
    NVL(total_review_count, 0) AS total_review_count
FROM VW_CONS_PRICE_BAND_360;
