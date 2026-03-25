# Tabular Format

## bmw_sales_raw

- year NUMERIC(4) NOT NULL CHECK(year>2000 AND year<3000)
- month NUMERIC(2) NOT NULL CHECK(month>0 AND month<13)
- region VARCHAR(20) NOT NULL
- model VARCHAR(20) NOT NULL
- units_sold INTEGER NOT NULL CHECK(units_sold>=0)
- avg_price_eur INTEGER NOT NULL CHECK(units_sold>=0)
- revenue_eur INTEGER NOT NULL CHECK(revenue_eur>=0)
- bev_share NUMERIC(4,4) NOT NULL CHECK(bev_share>=0 AND bev_share<=1)
- premium_share NUMERIC(6,3) NOT NULL CHECK(premium_share>=0 AND premium_share<=100)
- gdp_growth NUMERIC(5,3) NOT NULL
- fuel_price_index NUMERIC(5,3) NOT NULL CHECK(fuel_price_index >=0)
