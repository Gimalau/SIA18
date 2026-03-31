CREATE OR REPLACE DIRECTORY EXT_FILE_DS AS 'C:\FDB_DATA';
GRANT READ, WRITE ON DIRECTORY EXT_FILE_DS TO FDBO;

CREATE TABLE AM_DS2_CUSTOMER_BEHAVIOR_EXT
(
    order_id             VARCHAR2(50),
    customer_age         NUMBER,
    customer_gender      VARCHAR2(50),
    product_category     VARCHAR2(100),
    payment_method       VARCHAR2(100),
    order_value_usd      NUMBER,
    delivery_time_days   NUMBER,
    customer_rating      NUMBER,
    returned             VARCHAR2(20),
    order_date           VARCHAR2(50),
    returned_flag        NUMBER,
    order_year           NUMBER,
    order_month          NUMBER,
    order_day            NUMBER
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY EXT_FILE_DS
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY NEWLINE
        BADFILE EXT_FILE_DS:'am_ds2_customer_behavior.bad'
        LOGFILE EXT_FILE_DS:'am_ds2_customer_behavior.log'
        SKIP 1
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('ds2_customer_behavior_clean.csv')
)
REJECT LIMIT UNLIMITED;

CREATE OR REPLACE VIEW AM_DS2_CUSTOMER_BEHAVIOR_V AS
SELECT
    order_id,
    customer_age,
    customer_gender,
    product_category,
    payment_method,
    order_value_usd,
    delivery_time_days,
    customer_rating,
    returned,
    TO_DATE(order_date, 'YYYY-MM-DD') AS order_date,
    returned_flag,
    order_year,
    order_month,
    order_day,
    CASE
        WHEN order_value_usd < 25 THEN '0-25'
        WHEN order_value_usd < 50 THEN '25-50'
        WHEN order_value_usd < 100 THEN '50-100'
        WHEN order_value_usd < 250 THEN '100-250'
        ELSE '250+'
    END AS band_name
FROM AM_DS2_CUSTOMER_BEHAVIOR_EXT;
