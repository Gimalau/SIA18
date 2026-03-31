-- =========================================================
-- DS1 - PostgreSQL + PostgREST
-- Structura sursei relationale din PostgreSQL
-- =========================================================

-- Script-ul documenteaza structura folosita in PostgreSQL pentru sursa DS1 expusa prin PostgREST.

DROP TABLE IF EXISTS retail_transactions_raw;

CREATE TABLE retail_transactions_raw (
    row_id                  BIGSERIAL PRIMARY KEY,
    invoice_no              VARCHAR(20),
    stock_code              VARCHAR(30),
    description             TEXT,
    quantity                INTEGER,
    invoice_date            TIMESTAMP,
    unit_price              NUMERIC(12,4),
    customer_id             BIGINT,
    country                 VARCHAR(100),
    is_cancellation         BOOLEAN,
    is_return               BOOLEAN,
    has_valid_price         BOOLEAN,
    has_valid_description   BOOLEAN,
    line_amount             NUMERIC(14,4),
    invoice_year            INTEGER,
    invoice_month           INTEGER,
    invoice_day             INTEGER,
    invoice_hour            INTEGER
);

CREATE OR REPLACE VIEW vw_retail_transactions AS
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
    invoice_hour
FROM retail_transactions_raw;
