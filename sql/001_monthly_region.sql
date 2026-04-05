TRUNCATE TABLE monthly_region_sales;

INSERT INTO monthly_region_sales (
    year,
    month,
    region,
    total_units_sold,
    total_avg_price_eur,
    total_revenue_eur
)
SELECT 
    year,
    month,
    region,
    SUM(units_sold),
    ROUND((SUM(units_sold*avg_price_eur) / NULLIF(SUM(units_sold),0))::NUMERIC,2),
    SUM(revenue_eur)
FROM bmw_sales_clean
WHERE 
    units_sold IS NOT NULL
    AND avg_price_eur IS NOT NULL
    AND revenue_eur IS NOT NULL
GROUP BY year, month, region
ORDER BY region, year, month;