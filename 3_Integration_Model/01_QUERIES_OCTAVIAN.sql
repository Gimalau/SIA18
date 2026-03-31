-- =========================================================
-- INTEROGARI ANALITICE - MEMBRUL 1
-- Sursa principala: FACT_RETAIL_SALES_V
-- =========================================================

-- 1. Agregare ierarhica ROLLUP pe an, luna si banda de pret
SELECT
    CASE
        WHEN invoice_year IS NULL THEN 'TOTAL_GENERAL'
        ELSE TO_CHAR(invoice_year)
    END AS invoice_year,
    CASE
        WHEN invoice_month IS NULL THEN 'TOTAL_AN'
        ELSE TO_CHAR(invoice_month)
    END AS invoice_month,
    CASE
        WHEN band_name IS NULL THEN 'TOTAL_LUNA'
        ELSE band_name
    END AS band_name,
    COUNT(*) AS nr_tranzactii,
    SUM(quantity) AS total_quantity,
    SUM(line_amount) AS total_sales_amount
FROM FACT_RETAIL_SALES_V
GROUP BY ROLLUP(invoice_year, invoice_month, band_name)
ORDER BY invoice_year NULLS LAST, invoice_month NULLS LAST, band_name NULLS LAST;


-- 2. Agregare multidimensionala CUBE pe tara si banda de pret
SELECT
    CASE
        WHEN country IS NULL THEN 'TOATE_TARILE'
        ELSE country
    END AS country,
    CASE
        WHEN band_name IS NULL THEN 'TOATE_BENZILE'
        ELSE band_name
    END AS band_name,
    COUNT(*) AS sales_rows,
    SUM(quantity) AS total_quantity,
    SUM(line_amount) AS total_sales_amount,
    ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM FACT_RETAIL_SALES_V
GROUP BY CUBE(country, band_name)
ORDER BY country NULLS LAST, band_name NULLS LAST;


-- 3. Agregare flexibila cu GROUPING SETS
SELECT
    CASE
        WHEN GROUPING(invoice_year) = 1 THEN 'TOTI_ANII'
        ELSE TO_CHAR(invoice_year)
    END AS invoice_year,
    CASE
        WHEN GROUPING(country) = 1 THEN 'TOATE_TARILE'
        ELSE country
    END AS country,
    CASE
        WHEN GROUPING(band_name) = 1 THEN 'TOATE_BENZILE'
        ELSE band_name
    END AS band_name,
    COUNT(*) AS sales_rows,
    SUM(line_amount) AS total_sales_amount
FROM FACT_RETAIL_SALES_V
GROUP BY GROUPING SETS (
    (invoice_year, country, band_name),
    (invoice_year, country),
    (country, band_name),
    (invoice_year),
    ()
)
ORDER BY invoice_year, country, band_name;
