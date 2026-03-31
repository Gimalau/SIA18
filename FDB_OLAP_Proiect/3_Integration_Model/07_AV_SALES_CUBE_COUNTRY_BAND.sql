-- =========================================================
-- AV_SALES_CUBE_COUNTRY_BAND
-- =========================================================

CREATE OR REPLACE VIEW AV_SALES_CUBE_COUNTRY_BAND AS
SELECT
    country,
    band_name,
    COUNT(*) AS sales_rows,
    SUM(quantity) AS total_quantity,
    SUM(line_amount) AS total_sales_amount,
    AVG(unit_price) AS avg_unit_price
FROM FACT_RETAIL_SALES_V
GROUP BY CUBE(country, band_name);
