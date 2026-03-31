-- =========================================================
-- APEX - interogarile folosite in paginile aplicatiei
-- Aplicatie: FDBO_Analytics_App
-- =========================================================

-- Pagina / Regiunea 1:
-- FACT_PRICE_BAND_360_WebView
-- Tip: Interactive Grid

SELECT
    band_id,
    band_name,
    sales_rows,
    total_sales_amount,
    avg_unit_price,
    behavior_rows,
    avg_order_value,
    avg_customer_rating,
    product_rows,
    avg_product_price,
    avg_rating_stars,
    total_review_count
FROM FACT_PRICE_BAND_360_V
ORDER BY band_id;


-- Pagina / Regiunea 2:
-- PRICE_BAND_STATS_Chart
-- Tip: Bar Chart

SELECT
    band_id,
    band_name,
    total_sales_amount
FROM AV_PRICE_BAND_STATS_V
ORDER BY band_id;
