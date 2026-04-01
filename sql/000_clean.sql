DROP TABLE IF EXISTS bmw_sales_clean;

CREATE TABLE bmw_sales_clean AS
SELECT 
    year,
    month,
    region,
    model,
    units_sold,
    avg_price_eur,
    CASE
        WHEN bsr.revenue_eur<>units_sold*avg_price_eur THEN units_sold*avg_price_eur
        ELSE bsr.revenue_eur
    END AS revenue_eur,
    CASE
        WHEN bsr.bev_share<0 THEN NULL
        ELSE bsr.bev_share
    END AS bev_share,
    CASE
        WHEN bsr.premium_share<0 THEN NULL
        ELSE bsr.premium_share
    END AS premium_share,
    gdp_growth,
    CASE
        WHEN bsr.fuel_price_index<0 THEN NULL
        ELSE bsr.fuel_price_index
    END AS fuel_price_index
FROM bmw_sales_raw bsr
WHERE 
    year>2000 AND year<3000 AND year IS NOT NULL
    AND month>0 AND month<13 AND month IS NOT NULL
    AND region IS NOT NULL
    AND model IS NOT NULL
    AND units_sold>=0 AND units_sold IS NOT NULL
    AND avg_price_eur>=0 AND avg_price_eur IS NOT NULL;

ALTER TABLE bmw_sales_clean ADD CONSTRAINT bsc_pk PRIMARY KEY (year, month, region, model);