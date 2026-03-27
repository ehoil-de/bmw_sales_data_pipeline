DROP TABLE IF EXISTS sales_gdp_feature;

CREATE TABLE sales_gdp_feature AS
SELECT
    region,
    gdp_growth,
    ROUND(SUM(units_sold*premium_share) / NULLIF(SUM(units_sold),0),2) AS total_premium_share,
    ROUND(SUM(units_sold*bev_share) / NULLIF(SUM(units_sold), 0),3) AS total_bev_share,
    SUM(units_sold) AS total_units_sold,
    SUM(revenue_eur) AS total_revenue_eur
FROM bmw_sales_raw
GROUP BY region, gdp_growth
ORDER BY region, gdp_growth;