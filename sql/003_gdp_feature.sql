DROP TABLE IF EXISTS sales_gdp_feature;

CREATE TABLE sales_gdp_feature AS
SELECT
    region,
    gdp_growth,
    ROUND((SUM(units_sold*premium_share) / NULLIF(SUM(units_sold),0))::NUMERIC,2) AS total_premium_share,
    ROUND((SUM(units_sold*bev_share) / NULLIF(SUM(units_sold), 0))::NUMERIC,3) AS total_bev_share,
    SUM(units_sold) AS total_units_sold,
    SUM(revenue_eur) AS total_revenue_eur
FROM bmw_sales_clean
WHERE
    units_sold IS NOT NULL
    AND revenue_eur IS NOT NULL
    AND premium_share IS NOT NULL
    AND bev_share IS NOT NULL
GROUP BY region, gdp_growth
ORDER BY region, gdp_growth;

ALTER TABLE sales_gdp_feature ADD CONSTRAINT sgf_pk PRIMARY KEY (region, gdp_growth);