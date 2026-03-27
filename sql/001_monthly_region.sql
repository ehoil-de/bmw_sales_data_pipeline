DROP TABLE IF EXISTS monthly_region_sales;

CREATE TABLE monthly_region_sales AS
SELECT 
    year,
    month,
    region,
    SUM(units_sold) AS total_units_sold,
    ROUND((SUM(units_sold*avg_price_eur) / NULLIF(SUM(units_sold),0))::NUMERIC,2) AS total_avg_price_eur,
    SUM(revenue_eur) AS total_revenue_eur
FROM bmw_sales_clean
GROUP BY year, month, region
ORDER BY region, year, month;

ALTER TABLE monthly_region_sales ADD CONSTRAINT mrs_pk PRIMARY KEY (year, month, region);