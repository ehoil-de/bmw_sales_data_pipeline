DROP TABLE IF EXISTS bmw_sales_clean;

CREATE TABLE bmw_sales_clean AS
SELECT *
FROM bmw_sales_raw
WHERE 
    year>2000 AND year<3000 AND year IS NOT NULL
    AND month>0 AND month<13 AND month IS NOT NULL
    AND region IS NOT NULL
    AND model IS NOT NULL
    AND units_sold>=0 AND units_sold IS NOT NULL
    AND avg_price_eur>=0
    AND revenue_eur>=0
    AND units_sold*avg_price_eur=revenue_eur
    AND bev_share>=0
    AND premium_share>=0
    AND fuel_price_index>=0;