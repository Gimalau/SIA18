-- =========================================================
-- DIM_PRICE_BAND
-- =========================================================

CREATE TABLE DIM_PRICE_BAND (
    band_id        NUMBER PRIMARY KEY,
    band_name      VARCHAR2(30),
    min_price_usd  NUMBER(12,2),
    max_price_usd  NUMBER(12,2)
);

INSERT INTO DIM_PRICE_BAND VALUES (1, '0-25',    0,    25);
INSERT INTO DIM_PRICE_BAND VALUES (2, '25-50',   25,   50);
INSERT INTO DIM_PRICE_BAND VALUES (3, '50-100',  50,  100);
INSERT INTO DIM_PRICE_BAND VALUES (4, '100-250', 100, 250);
INSERT INTO DIM_PRICE_BAND VALUES (5, '250+',    250, NULL);

COMMIT;
