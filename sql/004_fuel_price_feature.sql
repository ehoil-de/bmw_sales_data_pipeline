DROP TABLE IF EXISTS sales_fuel_index_feature;

CREATE TABLE sales_fuel_index_feature AS
SELECT
    region,
    fuel_price_index_low,
    ROUND((SUM(units_sold * premium_share) / NULLIF(SUM(units_sold),0))::NUMERIC, 2) AS total_premium_share,
    ROUND((SUM(units_sold * bev_share) / NULLIF(SUM(units_sold),0))::NUMERIC, 3) AS total_bev_share,
    SUM(units_sold) AS total_units_sold,
    SUM(revenue_eur) AS total_revenue_eur
FROM (
    SELECT
        region,
        units_sold,
        premium_share,
        bev_share,
        revenue_eur,
        ROUND(fuel_price_index::NUMERIC(4,3), 1) AS fuel_price_index_low
    FROM bmw_sales_raw
) bsc
GROUP BY region, fuel_price_index_low
ORDER BY region, fuel_price_index_low;