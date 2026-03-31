-- =========================================================
-- INTEROGARI REST / WEB - MEMBRUL 3
-- Resurse REST pentru ranking, timp si performanta pe tari
-- =========================================================

-- 1. View REST pentru ranking-ul benzilor de pret
CREATE OR REPLACE VIEW WEB_M3_RANK_V AS
SELECT
    band_id,
    band_name,
    total_sales_amount,
    avg_rating_stars,
    sales_rank,
    rating_rank,
    sales_amount_per_row,
    reviews_per_product
FROM AV_PRICE_BAND_STATS_V;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M3_RANK_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm3-ranking',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m3-ranking/


-- 2. View REST pentru analiza evolutiei in timp
CREATE OR REPLACE VIEW WEB_M3_TIME_V AS
SELECT
    invoice_year,
    invoice_month,
    COUNT(*) AS sales_rows,
    SUM(quantity) AS total_quantity,
    SUM(line_amount) AS total_sales_amount,
    ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM FACT_RETAIL_SALES_V
GROUP BY invoice_year, invoice_month;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M3_TIME_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm3-time-trend',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m3-time-trend/


-- 3. View REST pentru performanta pe tari si benzi de pret
CREATE OR REPLACE VIEW WEB_M3_COUNTRY_V AS
SELECT
    country,
    band_name,
    COUNT(*) AS sales_rows,
    SUM(quantity) AS total_quantity,
    SUM(line_amount) AS total_sales_amount,
    ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM FACT_RETAIL_SALES_V
GROUP BY country, band_name;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M3_COUNTRY_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm3-country-performance',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m3-country-performance/
