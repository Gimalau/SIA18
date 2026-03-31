-- =========================================================
-- DIM_TIME_DS1_V
-- =========================================================

CREATE OR REPLACE VIEW DIM_TIME_DS1_V AS
SELECT DISTINCT
    invoice_year,
    invoice_month,
    invoice_day,
    invoice_hour,
    invoice_date
FROM AM_DS1_RETAIL_PGRST_V;
