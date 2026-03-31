-- =========================================================
-- INTEROGARI ANALITICE - MEMBRUL 2
-- Sursa principala: FACT_PRICE_BAND_360_V
-- =========================================================

-- 1. Segmentarea benzilor de pret dupa interesul utilizatorilor
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
         END
ORDER BY total_sales_amount DESC;


-- 2. Clasament al benzilor de pret dupa vanzari si review-uri
SELECT
    band_name,
    total_sales_amount,
    behavior_rows,
    product_rows,
    total_review_count,
    ROUND(total_sales_amount / NULLIF(behavior_rows, 0), 2) AS sales_per_behavior_row,
    DENSE_RANK() OVER (ORDER BY total_sales_amount DESC) AS sales_rank,
    DENSE_RANK() OVER (ORDER BY total_review_count DESC) AS review_rank
FROM FACT_PRICE_BAND_360_V
ORDER BY sales_rank, band_name;


-- 3. Agregare pe segmente de portofoliu si rating
SELECT
    CASE
        WHEN GROUPING(
            CASE
                WHEN product_rows >= 200 THEN 'PORTOFOLIU_MARE'
                WHEN product_rows >= 50 THEN 'PORTOFOLIU_MEDIU'
                ELSE 'PORTOFOLIU_MIC'
            END
        ) = 1 THEN 'TOTAL_GENERAL'
        ELSE
            CASE
                WHEN product_rows >= 200 THEN 'PORTOFOLIU_MARE'
                WHEN product_rows >= 50 THEN 'PORTOFOLIU_MEDIU'
                ELSE 'PORTOFOLIU_MIC'
            END
    END AS portofoliu_segment,
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
    SUM(total_sales_amount) AS total_sales_amount,
    SUM(total_review_count) AS total_review_count
FROM FACT_PRICE_BAND_360_V
GROUP BY GROUPING SETS (
    (
        CASE
            WHEN product_rows >= 200 THEN 'PORTOFOLIU_MARE'
            WHEN product_rows >= 50 THEN 'PORTOFOLIU_MEDIU'
            ELSE 'PORTOFOLIU_MIC'
        END,
        CASE
            WHEN avg_rating_stars >= 4.40 THEN 'RATING_RIDICAT'
            WHEN avg_rating_stars >= 4.20 THEN 'RATING_MEDIU'
            ELSE 'RATING_SCAZUT'
        END
    ),
    (
        CASE
            WHEN product_rows >= 200 THEN 'PORTOFOLIU_MARE'
            WHEN product_rows >= 50 THEN 'PORTOFOLIU_MEDIU'
            ELSE 'PORTOFOLIU_MIC'
        END
    ),
    ()
)
ORDER BY 1, 2;
