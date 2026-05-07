--------------------------------------------------------------------------------
-- DS_SQL_PG.sql
-- DS1 Access Model Integration - PostgreSQL Retail Transactions
-- Source microservice:
-- http://localhost:8090/DSA-SQL-JDBCService/rest/retail/RetailTransactionsView
--
-- Architecture:
-- PostgreSQL DS1 -> DSA-SQL-JDBCService -> REST Endpoint -> SparkSQL View
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS retail_transactions_view;
DROP VIEW IF EXISTS RETAIL_TRANSACTIONS_JSON_VIEW;

--------------------------------------------------------------------------------
-- STEP 1: Create SparkSQL JSON view by invoking the REST endpoint
--------------------------------------------------------------------------------

SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'RETAIL_TRANSACTIONS_JSON_VIEW',
               'http://localhost:8090/DSA-SQL-JDBCService/rest/retail/RetailTransactionsView'
       );

--------------------------------------------------------------------------------
-- STEP 2: Create structured SparkSQL view for DS1
-- Important:
-- RETAIL_TRANSACTIONS_JSON_VIEW already contains STRUCT objects,
-- therefore from_json() is not needed here.
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW retail_transactions_view AS
SELECT
    r.rowId AS row_id,
    r.invoiceNo AS invoice_no,
    r.stockCode AS stock_code,
    r.description AS description,
    CAST(r.quantity AS INT) AS quantity,
    r.invoiceDate AS invoice_date,
    CAST(r.unitPrice AS DECIMAL(12,4)) AS unit_price,
    r.customerId AS customer_id,
    r.country AS country,
    r.isCancellation AS is_cancellation,
    r.isReturn AS is_return
FROM RETAIL_TRANSACTIONS_JSON_VIEW
         LATERAL VIEW explode(`array`) exploded_table AS r;

--------------------------------------------------------------------------------
-- STEP 3: Validation queries
--------------------------------------------------------------------------------

SELECT
    row_id,
    invoice_no,
    stock_code,
    quantity,
    unit_price,
    country
FROM retail_transactions_view
         LIMIT 10;

SELECT COUNT(*) AS retail_rows
FROM retail_transactions_view;