# bmw_sales_data_pipeline

## Project Overview

This project is a beginner data engineering pipeline built with BMW global sales data.
It focuses on how raw CSV data can be ingested, validated, and transformed into structured analytical tables.

The current version of the project emphasizes:

- raw data ingestion with Python and Pandas
- loading data into PostgreSQL
- basic duplicate prevention before insert
- SQL-based transformation into aggregation and feature tables
- documentation of grain, lineage, and table structure

**This project is currently in progress.**
**The current implementation includes a runnable ingestion-to-transform pipeline and supporting documentation.**

---

## What I Built

- Extracted data from CSV using Python
- Removed duplicate rows from source CSV files before loading
- Compared incoming rows with existing raw-table records to prevent repeated inserts
- Loaded data into a relational database
- Designed a raw data table with constraints to ensure data quality
- Built SQL-based aggregation and feature tables for downstream analysis
- Added a pipeline entry point to run ingestion and transformations in sequence
- Documented the current data model and ERD

---

## Pipeline Flow

> bmw_global_sales_2018_2025.csv
> -> Extract (Python / Pandas)
> -> Remove source-level duplicates with `drop_duplicates()`
> -> Compare with existing raw-table records using `pandas.merge()`
> -> Load (PostgreSQL)
> -> Transform (SQL)
> -> `monthly_region_sales`
> -> `monthly_model_sales`
> -> `sales_gdp_feature`
> -> `sales_fuel_index_feature`

---

## Current Database Design

I designed a **bmw_sales_raw** table with constraints to maintain data integrity.

I also created downstream analytical tables for aggregation and feature use cases.

Key design decisions:

**NOT NULL constraints**

- Ensures essential fields are always present

**Data type constraints**

- Prevent invalid or malformed data

**Explicit table grain**

- Keeps each derived table aligned to a clear analytical purpose

**Duplicate prevention before insert**

- Source-level duplicates are removed before loading
- Incoming rows are compared against existing raw-table records before insertion

---

## Project Structure

- `run_pipeline.py`: runs raw ingestion and SQL transformations
- `scripts/ingesting.py`: removes duplicate rows from source CSV files, checks against existing raw-table records, and loads new rows into `bmw_sales_raw`
- `sql/`: contains SQL files that create aggregation and feature tables
- `docs/data_model.md`: documents the current table structure, grain, and lineage
- `docs/ERD/ERD.dbml`: source ERD definition
- `docs/ERD/ERD.png`: rendered ERD image

---

## Key Learnings

- Why `to_sql(..., if_exists="replace")` can break an existing schema
- Why duplicate prevention needs an earlier defensive layer before database constraints
- Why table grain should be defined explicitly when designing derived tables

---

## Limitations

- The current pipeline still depends on direct raw-to-derived transformations
- Duplicate prevention is handled in the ingestion logic, not through a more robust incremental load design
- Feature tables are still closer to analytical summaries than fully developed ML feature sets

---

## Future Improvements

- Add a clean/staging layer between raw and derived tables
- Improve feature tables so they better match real feature engineering use cases
- Strengthen the pipeline structure with more robust validation and execution handling

---
