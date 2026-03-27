DROP TABLE IF EXISTS monthly_model_sales;

CREATE TABLE monthly_model_sales AS
SELECT
    year,
    month,
    model,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(units_sold*avg_price_eur)::NUMERIC / NULLIF(SUM(units_sold),0),2) AS total_avg_price_eur,
    SUM(revenue_eur) AS total_revenue_eur
FROM bmw_sales_raw
GROUP BY year, month, model
ORDER BY model, year, month;