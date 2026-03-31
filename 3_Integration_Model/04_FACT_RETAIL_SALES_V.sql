-- =========================================================
-- FACT_RETAIL_SALES_V
-- =========================================================

CREATE OR REPLACE VIEW FACT_RETAIL_SALES_V AS
SELECT
    row_id,
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
    line_amount,
    invoice_year,
    invoice_month,
    invoice_day,
    invoice_hour,
    CASE
        WHEN unit_price < 25 THEN '0-25'
        WHEN unit_price < 50 THEN '25-50'
        WHEN unit_price < 100 THEN '50-100'
        WHEN unit_price < 250 THEN '100-250'
        ELSE '250+'
    END AS band_name
FROM AM_DS1_RETAIL_PGRST_V;
