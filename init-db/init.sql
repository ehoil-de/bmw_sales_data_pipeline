CREATE TABLE IF NOT EXISTS bmw_sales_raw (
    year                SMALLINT,
    month               SMALLINT,
    region              TEXT,
    model               TEXT,
    units_sold          BIGINT,
    avg_price_eur       BIGINT,
    revenue_eur         BIGINT,
    bev_share           DOUBLE PRECISION,
    premium_share       DOUBLE PRECISION,
    gdp_growth          DOUBLE PRECISION,
    fuel_price_index    DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS bmw_sales_clean (
    year                SMALLINT,
    month               SMALLINT,
    region              TEXT,
    model               TEXT,
    units_sold          BIGINT,
    avg_price_eur       BIGINT,
    revenue_eur         BIGINT,
    bev_share           DOUBLE PRECISION,
    premium_share       DOUBLE PRECISION,
    gdp_growth          DOUBLE PRECISION,
    fuel_price_index    DOUBLE PRECISION,
    CONSTRAINT pk_bmw_sales_clean PRIMARY KEY (year, month, region, model)
);

CREATE TABLE IF NOT EXISTS monthly_region_sales (
    year                 SMALLINT NOT NULL,
    month                SMALLINT NOT NULL,
    region               TEXT NOT NULL,
    total_units_sold     BIGINT NOT NULL,
    total_avg_price_eur  NUMERIC(12,2) NOT NULL,
    total_revenue_eur    BIGINT NOT NULL,
    CONSTRAINT pk_mrs PRIMARY KEY (year, month, region)
);

CREATE TABLE IF NOT EXISTS monthly_model_sales (
    year                 SMALLINT NOT NULL,
    month                SMALLINT NOT NULL,
    model                TEXT NOT NULL,
    total_units_sold     BIGINT NOT NULL,
    total_avg_price_eur  NUMERIC(12,2) NOT NULL,
    total_revenue_eur    BIGINT NOT NULL,
    CONSTRAINT pk_mms PRIMARY KEY (year, month, model)
);

CREATE TABLE IF NOT EXISTS sales_gdp_feature (
    region               TEXT NOT NULL,
    gdp_growth           DOUBLE PRECISION NOT NULL,
    total_premium_share  NUMERIC(6,2) NOT NULL,
    total_bev_share      NUMERIC(6,3) NOT NULL,
    total_units_sold     BIGINT NOT NULL,
    total_revenue_eur    BIGINT NOT NULL,
    CONSTRAINT pk_sgf PRIMARY KEY (region, gdp_growth)
);

CREATE TABLE IF NOT EXISTS sales_fuel_index_feature (
    region                TEXT NOT NULL,
    fuel_price_index_low  NUMERIC(4,1) NOT NULL,
    total_premium_share   NUMERIC(6,2) NOT NULL,
    total_bev_share       NUMERIC(6,3) NOT NULL,
    total_units_sold      BIGINT NOT NULL,
    total_revenue_eur     BIGINT NOT NULL,
    CONSTRAINT pk_fif PRIMARY KEY (region, fuel_price_index_low)
);