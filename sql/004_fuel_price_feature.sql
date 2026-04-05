TRUNCATE TABLE sales_fuel_index_feature;

INSERT INTO sales_fuel_index_feature (
    region,
    fuel_price_index_low,
    total_premium_share,
    total_bev_share,
    total_units_sold,
    total_revenue_eur
)
SELECT
    region,
    fuel_price_index_low,
    ROUND((SUM(units_sold * premium_share) / NULLIF(SUM(units_sold),0))::NUMERIC, 2),
    ROUND((SUM(units_sold * bev_share) / NULLIF(SUM(units_sold),0))::NUMERIC, 3),
    SUM(units_sold),
    SUM(revenue_eur)
FROM (
    SELECT
        region,
        units_sold,
        premium_share,
        bev_share,
        revenue_eur,
        ROUND(fuel_price_index::NUMERIC(4,3), 1) AS fuel_price_index_low
    FROM bmw_sales_clean
) bsc
WHERE
    bsc.units_sold IS NOT NULL
    AND bsc.premium_share IS NOT NULL
    AND bsc.bev_share IS NOT NULL
    AND bsc.revenue_eur IS NOT NULL
    AND bsc.fuel_price_index_low IS NOT NULL
GROUP BY region, fuel_price_index_low
ORDER BY region, fuel_price_index_low;