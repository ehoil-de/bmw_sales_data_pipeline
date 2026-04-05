TRUNCATE TABLE sales_gdp_feature;

INSERT INTO sales_gdp_feature (
    region,
    gdp_growth,
    total_premium_share,
    total_bev_share,
    total_units_sold,
    total_revenue_eur
)
SELECT
    region,
    gdp_growth,
    ROUND((SUM(units_sold*premium_share) / NULLIF(SUM(units_sold),0))::NUMERIC,2),
    ROUND((SUM(units_sold*bev_share) / NULLIF(SUM(units_sold), 0))::NUMERIC,3),
    SUM(units_sold),
    SUM(revenue_eur)
FROM bmw_sales_clean
WHERE
    units_sold IS NOT NULL
    AND revenue_eur IS NOT NULL
    AND premium_share IS NOT NULL
    AND bev_share IS NOT NULL
GROUP BY region, gdp_growth
ORDER BY region, gdp_growth;