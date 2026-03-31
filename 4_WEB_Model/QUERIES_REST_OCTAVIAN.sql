-- =========================================================
-- INTEROGARI REST / WEB - MEMBRUL 1
-- Resurse REST bazate pe view-uri analitice principale
-- =========================================================

-- 1. View REST pentru agregarea ierarhica ROLLUP
CREATE OR REPLACE VIEW WEB_M1_ROLLUP_V AS
SELECT
    invoice_year,
    invoice_month,
    band_name,
    sales_rows,
    total_quantity,
    total_sales_amount,
    avg_unit_price
FROM AV_SALES_ROLLUP_TIME_BAND;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M1_ROLLUP_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm1-rollup',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m1-rollup/


-- 2. View REST pentru agregarea multidimensionala CUBE
CREATE OR REPLACE VIEW WEB_M1_CUBE_V AS
SELECT
    country,
    band_name,
    sales_rows,
    total_quantity,
    total_sales_amount,
    avg_unit_price
FROM AV_SALES_CUBE_COUNTRY_BAND;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M1_CUBE_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm1-cube',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m1-cube/


-- 3. View REST pentru statistici pe benzile de pret
CREATE OR REPLACE VIEW WEB_M1_STATS_V AS
SELECT
    band_id,
    band_name,
    total_sales_amount,
    avg_rating_stars,
    sales_rank,
    rating_rank
FROM AV_PRICE_BAND_STATS_V;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M1_STATS_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm1-stats',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m1-stats/
