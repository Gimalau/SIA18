--------------------------------------------------------------------------------
-- DS_MongoDB.sql
-- DS3 Access Model Integration - MongoDB Amazon Products
-- Source microservice:
-- http://localhost:8093/DSA-NoSQL-MongoDBService/rest/amazon/AmazonProductsView
--
-- Architecture:
-- MongoDB DS3 -> DSA-NoSQL-MongoDBService -> REST Endpoint -> SparkSQL View
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS amazon_products_view;
DROP VIEW IF EXISTS AMAZON_PRODUCTS_JSON_VIEW;

--------------------------------------------------------------------------------
-- STEP 1: Create SparkSQL JSON view by invoking the REST endpoint
--------------------------------------------------------------------------------

SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'AMAZON_PRODUCTS_JSON_VIEW',
               'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/amazon/AmazonProductsView'
       );

--------------------------------------------------------------------------------
-- STEP 2: Create structured SparkSQL view for DS3
-- Important:
-- AMAZON_PRODUCTS_JSON_VIEW already contains STRUCT objects,
-- therefore from_json() is not needed here.
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW amazon_products_view AS
SELECT
    a.mongoId AS mongo_id,
    a.asin AS asin,
    a.title AS title,
    a.brandName AS brand_name,
    a.availability AS availability,
    a.categoryMain AS category_main,
    a.categorySub AS category_sub,
    a.categoryLeaf AS category_leaf,
    CAST(a.priceUsd AS DECIMAL(12,2)) AS price_usd,
    CAST(a.listPriceUsd AS DECIMAL(12,2)) AS list_price_usd,
    CAST(a.ratingStars AS DECIMAL(4,2)) AS rating_stars,
    CAST(a.ratingCount AS INT) AS rating_count,
    CAST(a.recentPurchasesNum AS INT) AS recent_purchases_num,
    a.sellerName AS seller_name,
    CAST(a.reviewCount AS INT) AS review_count,
    a.sampleReviewTitle AS sample_review_title,
    a.sampleReviewText AS sample_review_text
FROM AMAZON_PRODUCTS_JSON_VIEW
         LATERAL VIEW explode(`array`) exploded_table AS a;

--------------------------------------------------------------------------------
-- STEP 3: Validation queries
--------------------------------------------------------------------------------

SELECT
    asin,
    title,
    brand_name,
    category_main,
    category_sub,
    price_usd,
    rating_stars,
    rating_count,
    seller_name
FROM amazon_products_view
         LIMIT 10;

SELECT COUNT(*) AS amazon_products_rows
FROM amazon_products_view;