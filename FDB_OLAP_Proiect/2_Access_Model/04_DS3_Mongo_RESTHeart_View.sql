-- =========================================================
-- DS3 - MongoDB accessed through RESTHeart + UTL_HTTP + JSON_TABLE
-- Schema: FDBO
-- =========================================================

BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace(
    host => 'localhost',
    lower_port => 8081,
    upper_port => 8081,
    ace => xs$ace_type(
      privilege_list => xs$name_list('http'),
      principal_name => 'FDBO',
      principal_type => xs_acl.ptype_db
    )
  );
END;
/
COMMIT;

CREATE OR REPLACE FUNCTION get_restheart_data_media(
    pURL      VARCHAR2,
    pUserPass VARCHAR2
) RETURN CLOB IS
    l_req    UTL_HTTP.req;
    l_resp   UTL_HTTP.resp;
    l_buffer VARCHAR2(32767);
    l_clob   CLOB;
BEGIN
    DBMS_LOB.createtemporary(l_clob, TRUE);

    l_req := UTL_HTTP.begin_request(pURL);
    UTL_HTTP.set_header(
        l_req,
        'Authorization',
        'Basic ' ||
        UTL_RAW.cast_to_varchar2(
            UTL_ENCODE.base64_encode(
                UTL_I18N.string_to_raw(pUserPass, 'AL32UTF8')
            )
        )
    );

    l_resp := UTL_HTTP.get_response(l_req);

    BEGIN
        LOOP
            UTL_HTTP.read_text(l_resp, l_buffer, 32767);
            DBMS_LOB.writeappend(l_clob, LENGTH(l_buffer), l_buffer);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.end_of_body THEN
            NULL;
    END;

    UTL_HTTP.end_response(l_resp);
    RETURN l_clob;
END;
/

CREATE OR REPLACE VIEW AM_DS3_AMAZON_PRODUCTS_MONGO_V AS
WITH j AS (
  SELECT get_restheart_data_media(
           'http://localhost:8081/mds/amazon_products?pagesize=1000',
           'admin:secret'
         ) AS doc
  FROM dual
)
SELECT
    asin,
    title,
    brand_name,
    availability,
    category_main,
    category_sub,
    category_leaf,
    price_usd,
    list_price_usd,
    rating_stars,
    rating_count,
    recent_purchases_num,
    seller_name,
    review_count,
    sample_review_title,
    sample_review_text
FROM JSON_TABLE(
       (SELECT doc FROM j),
       '$[*]'
       COLUMNS (
         asin                 VARCHAR2(40)   PATH '$.asin'                 NULL ON ERROR,
         title                VARCHAR2(1000) PATH '$.title'                NULL ON ERROR,
         brand_name           VARCHAR2(200)  PATH '$.brand_name'           NULL ON ERROR,
         availability         VARCHAR2(200)  PATH '$.availability'         NULL ON ERROR,
         category_main        VARCHAR2(200)  PATH '$.category_main'        NULL ON ERROR,
         category_sub         VARCHAR2(200)  PATH '$.category_sub'         NULL ON ERROR,
         category_leaf        VARCHAR2(200)  PATH '$.category_leaf'        NULL ON ERROR,
         price_usd            NUMBER         PATH '$.price_usd'            NULL ON ERROR,
         list_price_usd       NUMBER         PATH '$.list_price_usd'       NULL ON ERROR,
         rating_stars         NUMBER         PATH '$.rating_stars'         NULL ON ERROR,
         rating_count         NUMBER         PATH '$.rating_count'         NULL ON ERROR,
         recent_purchases_num NUMBER         PATH '$.recent_purchases_num' NULL ON ERROR,
         seller_name          VARCHAR2(300)  PATH '$.seller_name'          NULL ON ERROR,
         review_count         NUMBER         PATH '$.review_count'         NULL ON ERROR,
         sample_review_title  VARCHAR2(1000) PATH '$.sample_review_title'  NULL ON ERROR,
         sample_review_text   VARCHAR2(4000) PATH '$.sample_review_text'   NULL ON ERROR
       )
     );

CREATE OR REPLACE VIEW AM_DS3_AMAZON_PRODUCTS_V AS
SELECT *
FROM AM_DS3_AMAZON_PRODUCTS_MONGO_V;
