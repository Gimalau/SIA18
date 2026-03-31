-- =========================================================
-- INTEROGARI REST / WEB - MEMBRUL 2
-- Resurse REST orientate pe consolidare si segmentare
-- =========================================================

-- 1. View REST pentru consolidarea 360 pe banda de pret
CREATE OR REPLACE VIEW WEB_M2_CONS_V AS
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
FROM VW_CONS_PRICE_BAND_360;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M2_CONS_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm2-cons-360',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m2-cons-360/


-- 2. View REST pentru segmentarea dupa comportamentul utilizatorilor
CREATE OR REPLACE VIEW WEB_M2_BEHAV_SEG_V AS
SELECT
    CASE
        WHEN behavior_rows >= 1000 THEN 'INTERES_RIDICAT'
        WHEN behavior_rows >= 100 THEN 'INTERES_MEDIU'
        ELSE 'INTERES_SCAZUT'
    END AS segment_interes,
    COUNT(*) AS nr_benzi,
    SUM(total_sales_amount) AS total_sales_amount,
    ROUND(AVG(avg_order_value), 2) AS medie_order_value,
    ROUND(AVG(avg_customer_rating), 2) AS medie_rating_clienti
FROM FACT_PRICE_BAND_360_V
GROUP BY CASE
            WHEN behavior_rows >= 1000 THEN 'INTERES_RIDICAT'
            WHEN behavior_rows >= 100 THEN 'INTERES_MEDIU'
            ELSE 'INTERES_SCAZUT'
         END;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M2_BEHAV_SEG_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm2-behavior-segments',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m2-behavior-segments/


-- 3. View REST pentru analiza produselor si review-urilor
CREATE OR REPLACE VIEW WEB_M2_REVIEW_V AS
SELECT
    band_name,
    product_rows,
    total_review_count,
    avg_product_price,
    avg_rating_stars,
    reviews_per_product
FROM AV_PRICE_BAND_STATS_V;

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled        => TRUE,
    p_schema         => 'FDBO',
    p_object         => 'WEB_M2_REVIEW_V',
    p_object_type    => 'VIEW',
    p_object_alias   => 'm2-review-stats',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
-- URL test:
-- http://localhost:8080/ords/fdbo/m2-review-stats/
