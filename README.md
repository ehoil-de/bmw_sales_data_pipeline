# bmw_sales_data_pipeline

## Project Overview

This project is a beginner data engineering pipeline built with BMW global sales data.
It focuses on how raw CSV data can be ingested, validated, and transformed into structured analytical tables.

The current version of the project emphasizes:

- raw data ingestion with Python and Pandas
- a separate clean table for deduplication and light preprocessing
- loading data into PostgreSQL
- SQL-based transformation into aggregation and feature tables
- schema initialization managed inside the project
- documentation of grain, lineage, and table structure

**This project is currently in progress.**
**The current implementation includes a runnable ingestion-to-transform pipeline and supporting documentation.**

---

## What I Built

- Extracted data from CSV using Python
- Loaded data into a relational database
- Designed a raw data table to preserve source data before cleaning
- Added a clean table between raw ingestion and downstream analytical tables
- Built SQL-based aggregation and feature tables for downstream analysis
- Added database initialization SQL for table creation
- Added a pipeline entry point to run ingestion and transformations in sequence
- Documented the current data model and ERD

---

## Pipeline Flow

> bmw_global_sales_2018_2025.csv
> -> Extract (Python / Pandas)
> -> Load (PostgreSQL)
> -> Clean (`bmw_sales_clean`)
> -> Transform (SQL)
> -> `monthly_region_sales`
> -> `monthly_model_sales`
> -> `sales_gdp_feature`
> -> `sales_fuel_index_feature`

Current refresh strategy:

- `bmw_sales_raw` is loaded with append-based ingestion
- `bmw_sales_clean` is fully refreshed from `bmw_sales_raw` on each pipeline run
- downstream aggregation and feature tables are also fully refreshed on each pipeline run

---

## Current Database Design

I designed a **bmw_sales_raw** table to preserve source data before cleaning.

I also created a **bmw_sales_clean** table and downstream analytical tables for aggregation and feature use cases.

Key design decisions:

**NOT NULL constraints**

- Ensures essential fields are always present

**Data type constraints**

- Prevent invalid or malformed data

**Explicit table grain**

- Keeps each derived table aligned to a clear analytical purpose

**Clean-layer preprocessing**

- A separate clean table is used before aggregation and feature generation
- The current clean step removes duplicate rows at the clean-table grain and applies basic value handling before downstream transformations

**Full-refresh clean and derived layers**

- The clean table keeps its schema, but its contents are rebuilt on each run
- Aggregation and feature tables also keep their schema and are repopulated on each run
- This design helps reduce stale downstream results when upstream data changes

---

## Project Structure

- `run_pipeline.py`: runs raw ingestion and SQL transformations
- `scripts/ingesting.py`: loads CSV files from `datas/new` into `bmw_sales_raw`
- `docker_compose.yml`: starts a PostgreSQL container for the project
- `init-db/init.sql`: creates the project tables before running the pipeline
- `sql/000_clean.sql`: refreshes `bmw_sales_clean` from `bmw_sales_raw`
- `sql/`: contains SQL files that refresh clean, aggregation, and feature tables
- `docs/data_model.md`: documents the current table structure, grain, and lineage
- `docs/ERD/ERD.dbml`: source ERD definition
- `docs/ERD/ERD.png`: rendered ERD image

---

## Key Learnings

- Why `to_sql(..., if_exists="replace")` can break an existing schema
- Why raw tables should preserve source data before cleaning
- Why table grain should be defined explicitly when designing derived tables

---

## Limitations

- The current clean layer is still a simple SQL-based deduplication and preprocessing step and does not yet represent a full staging design
- Feature tables are still closer to analytical summaries than fully developed ML feature sets
- Database initialization is currently managed separately from `run_pipeline.py`, so tables must exist before the pipeline is executed

---

## Future Improvements

- Expand the clean layer into a more robust staging design
- Improve feature tables so they better match real feature engineering use cases
- Strengthen the pipeline structure with more robust validation and execution handling

---

## How To Run

### 1. Prepare environment variables

Set the database connection values in `.env`:

- `DB_USER`
- `DB_PASSWORD`
- `DB_HOST`
- `DB_NAME`

Current note:

- `run_pipeline.py` uses `DB_NAME`
- `scripts/ingesting.py` still uses a fixed database name and should be aligned with the same environment variable

### 2. Start PostgreSQL and initialize tables

The project includes:

- `docker_compose.yml` for starting PostgreSQL
- `init-db/init.sql` for creating the required tables

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the pipeline

```bash
python run_pipeline.py
```

This will:

- append CSV data from `datas/new` into `bmw_sales_raw`
- fully rebuild `bmw_sales_clean`
- fully rebuild the current aggregation and feature tables

---
