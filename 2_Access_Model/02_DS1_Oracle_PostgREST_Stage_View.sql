-- =========================================================
-- DS1 - Oracle access to PostgreSQL source exposed via PostgREST
-- Schema: FDBO
-- =========================================================

-- tabela de staging pentru incarcarea datelor expuse prin PostgREST
CREATE TABLE AM_DS1_RETAIL_PGRST (
    row_id                  NUMBER,
    invoice_no              VARCHAR2(20),
    stock_code              VARCHAR2(30),
    description             VARCHAR2(1000),
    quantity                NUMBER,
    invoice_date            TIMESTAMP,
    unit_price              NUMBER(12,4),
    customer_id             NUMBER,
    country                 VARCHAR2(100),
    is_cancellation         NUMBER(1),
    is_return               NUMBER(1),
    has_valid_price         NUMBER(1),
    has_valid_description   NUMBER(1),
    line_amount             NUMBER(14,4),
    invoice_year            NUMBER,
    invoice_month           NUMBER,
    invoice_day             NUMBER,
    invoice_hour            NUMBER
);

CREATE OR REPLACE VIEW AM_DS1_RETAIL_PGRST_V AS
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
    is_cancellation,
    is_return,
    has_valid_price,
    has_valid_description,
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
FROM AM_DS1_RETAIL_PGRST;
