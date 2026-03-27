DROP TABLE IF EXISTS bmw_sales_clean;

CREATE TABLE bmw_sales_clean AS
SELECT
    year,
    month,
    region,
    model,
    units_sold,
    avg_price_eur,
    revenue_eur,
    CASE
        WHEN bsr.bev_share < 0 THEN NULL
        ELSE bsr.bev_share
    END AS bev_share,
    premium_share,
    gdp_growth,
    fuel_price_index
FROM bmw_sales_raw bsr;