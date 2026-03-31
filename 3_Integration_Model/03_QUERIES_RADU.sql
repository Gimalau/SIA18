-- =========================================================
-- INTEROGARI ANALITICE - MEMBRUL 3
-- Surse principale: AV_PRICE_BAND_STATS_V, VW_CONS_PRICE_BAND_360
-- =========================================================

-- 1. Analiza comparativa intre benzi folosind LAG si LEAD
SELECT
    band_id,
    band_name,
    total_sales_amount,
    avg_rating_stars,
    sales_rank,
    rating_rank,
    LAG(total_sales_amount) OVER (ORDER BY band_id) AS prev_band_sales,
    LEAD(total_sales_amount) OVER (ORDER BY band_id) AS next_band_sales
FROM AV_PRICE_BAND_STATS_V
ORDER BY band_id;


-- 2. Segmentare de performanta dupa pozitia in clasament
SELECT
    CASE
        WHEN sales_rank = 1 THEN 'LIDER'
        WHEN sales_rank <= 3 THEN 'TOP_3'
        ELSE 'RESTUL_BENZILOR'
    END AS sales_segment,
    COUNT(*) AS nr_benzi,
    ROUND(AVG(avg_rating_stars), 2) AS avg_rating_stars,
    ROUND(AVG(sales_amount_per_row), 2) AS avg_sales_per_row,
    ROUND(AVG(reviews_per_product), 2) AS avg_reviews_per_product
FROM AV_PRICE_BAND_STATS_V
GROUP BY CASE
            WHEN sales_rank = 1 THEN 'LIDER'
            WHEN sales_rank <= 3 THEN 'TOP_3'
            ELSE 'RESTUL_BENZILOR'
         END
ORDER BY nr_benzi DESC;


-- 3. Agregare pe segmente de vanzare si segmente de rating
SELECT
    CASE
        WHEN GROUPING(
            CASE
                WHEN total_sales_amount >= 10000 THEN 'VANZARI_MARI'
                WHEN total_sales_amount >= 1000 THEN 'VANZARI_MEDII'
                ELSE 'VANZARI_REDUSE'
            END
        ) = 1 THEN 'TOTAL_GENERAL'
        ELSE
            CASE
                WHEN total_sales_amount >= 10000 THEN 'VANZARI_MARI'
                WHEN total_sales_amount >= 1000 THEN 'VANZARI_MEDII'
                ELSE 'VANZARI_REDUSE'
            END
    END AS sales_segment,
    CASE
        WHEN GROUPING(
            CASE
                WHEN avg_rating_stars >= 4.40 THEN 'RATING_RIDICAT'
                WHEN avg_rating_stars >= 4.20 THEN 'RATING_MEDIU'
                ELSE 'RATING_SCAZUT'
            END
        ) = 1 THEN 'TOTAL_SEGMENT'
        ELSE
            CASE
                WHEN avg_rating_stars >= 4.40 THEN 'RATING_RIDICAT'
                WHEN avg_rating_stars >= 4.20 THEN 'RATING_MEDIU'
                ELSE 'RATING_SCAZUT'
            END
    END AS rating_segment,
    COUNT(*) AS nr_benzi,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(avg_customer_rating), 2) AS avg_customer_rating
FROM VW_CONS_PRICE_BAND_360
GROUP BY GROUPING SETS (
    (
        CASE
            WHEN total_sales_amount >= 10000 THEN 'VANZARI_MARI'
            WHEN total_sales_amount >= 1000 THEN 'VANZARI_MEDII'
            ELSE 'VANZARI_REDUSE'
        END,
        CASE
            WHEN avg_rating_stars >= 4.40 THEN 'RATING_RIDICAT'
            WHEN avg_rating_stars >= 4.20 THEN 'RATING_MEDIU'
            ELSE 'RATING_SCAZUT'
        END
    ),
    (
        CASE
            WHEN total_sales_amount >= 10000 THEN 'VANZARI_MARI'
            WHEN total_sales_amount >= 1000 THEN 'VANZARI_MEDII'
            ELSE 'VANZARI_REDUSE'
        END
    ),
    ()
)
ORDER BY 1, 2;
