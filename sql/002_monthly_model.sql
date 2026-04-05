TRUNCATE TABLE monthly_model_sales;

INSERT INTO monthly_model_sales (
    year,
    month,
    model,
    total_units_sold,
    total_avg_price_eur,
    total_revenue_eur
)
SELECT
    year,
    month,
    model,
    SUM(units_sold),
    ROUND((SUM(units_sold*avg_price_eur) / NULLIF(SUM(units_sold),0))::NUMERIC,2),
    SUM(revenue_eur)
FROM bmw_sales_clean
WHERE
    units_sold IS NOT NULL
    AND avg_price_eur IS NOT NULL
    AND revenue_eur IS NOT NULL
GROUP BY year, month, model
ORDER BY model, year, month;