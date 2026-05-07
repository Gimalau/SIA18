--------------------------------------------------------------------------------
-- DS_DOC_CSV.sql
-- DS2 Access Model Integration - CSV Customer Behavior
-- Source microservice:
-- http://localhost:8097/DSA-DOC-CSVService/rest/customer-behavior/CustomerBehaviorViewCSV
--
-- Architecture:
-- CSV DS2 -> DSA-DOC-CSVService -> REST Endpoint -> SparkSQL View
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS customer_behavior_view;
DROP VIEW IF EXISTS CUSTOMER_BEHAVIOR_JSON_VIEW;

--------------------------------------------------------------------------------
-- STEP 1: Create SparkSQL JSON view by invoking the REST endpoint
--------------------------------------------------------------------------------

SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'CUSTOMER_BEHAVIOR_JSON_VIEW',
               'http://localhost:8097/DSA-DOC-CSVService/rest/customer-behavior/CustomerBehaviorViewCSV'
       );

--------------------------------------------------------------------------------
-- STEP 2: Create structured SparkSQL view for DS2
-- Important:
-- CUSTOMER_BEHAVIOR_JSON_VIEW already contains STRUCT objects,
-- therefore from_json() is not needed here.
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW customer_behavior_view AS
SELECT
    c.orderId AS order_id,
    c.customerId AS customer_id,
    CAST(c.age AS INT) AS age,
    c.gender AS gender,
    c.productCategory AS product_category,
    CAST(c.purchaseAmount AS DECIMAL(12,2)) AS purchase_amount,
    c.paymentMethod AS payment_method,
    CAST(c.deliveryTimeDays AS INT) AS delivery_time_days,
    CAST(c.customerRating AS INT) AS customer_rating,
    c.returnStatus AS return_status
FROM CUSTOMER_BEHAVIOR_JSON_VIEW
         LATERAL VIEW explode(`array`) exploded_table AS c;

--------------------------------------------------------------------------------
-- STEP 3: Validation queries
--------------------------------------------------------------------------------

SELECT
    order_id,
    customer_id,
    age,
    gender,
    product_category,
    purchase_amount,
    payment_method,
    delivery_time_days,
    customer_rating,
    return_status
FROM customer_behavior_view
         LIMIT 10;

SELECT COUNT(*) AS customer_behavior_rows
FROM customer_behavior_view;