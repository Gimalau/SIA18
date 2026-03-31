-- =========================================================
-- AV_PRICE_BAND_STATS_V
-- =========================================================

CREATE OR REPLACE VIEW AV_PRICE_BAND_STATS_V AS
SELECT
    band_id,
    band_name,
    sales_rows,
    total_sales_amount,
    behavior_rows,
    product_rows,
    total_review_count,
    ROUND(avg_unit_price, 2)      AS avg_unit_price,
    ROUND(avg_order_value, 2)     AS avg_order_value,
    ROUND(avg_customer_rating, 2) AS avg_customer_rating,
    ROUND(avg_product_price, 2)   AS avg_product_price,
    ROUND(avg_rating_stars, 2)    AS avg_rating_stars,
    ROUND(total_sales_amount / NULLIF(sales_rows, 0), 2)   AS sales_amount_per_row,
    ROUND(total_review_count / NULLIF(product_rows, 0), 2) AS reviews_per_product,
    DENSE_RANK() OVER (ORDER BY total_sales_amount DESC) AS sales_rank,
    DENSE_RANK() OVER (ORDER BY avg_rating_stars DESC NULLS LAST) AS rating_rank
FROM FACT_PRICE_BAND_360_V;
