INSERT INTO bmw_sales_clean (
    year,
    month,
    region,
    model,
    units_sold,
    avg_price_eur,
    revenue_eur,
    bev_share,
    premium_share,
    gdp_growth,
    fuel_price_index
    )
SELECT
    year,
    month,
    region,
    model,
    CASE
        WHEN bsr.units_sold<0 THEN NULL
        ELSE bsr.units_sold
    END AS units_sold,
    CASE
        WHEN bsr.avg_price_eur<0 THEN NULL
        ELSE bsr.avg_price_eur
    END AS avg_price_eur,
    CASE
        WHEN bsr.revenue_eur<0 THEN NULL
        ELSE bsr.revenue_eur
    END AS revenue_eur,
    CASE
        WHEN bsr.bev_share<0 THEN NULL
        ELSE bsr.bev_share
    END AS bev_share,
    CASE
        WHEN bsr.premium_share<0 THEN NULL
        ELSE bsr.premium_share
    END AS premium_share,
    gdp_growth,
    CASE
        WHEN bsr.fuel_price_index<0 THEN NULL
        ELSE bsr.fuel_price_index
    END AS fuel_price_index
FROM bmw_sales_raw bsr
WHERE  
    year>2000 AND year<3000 AND year IS NOT NULL
    AND month>0 AND month<13 AND month IS NOT NULL
    AND region IS NOT NULL
    AND model IS NOT NULL
ON CONFLICT (year, month, region, model)
DO NOTHING;