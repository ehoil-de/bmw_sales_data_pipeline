# bmw_sales_data_pipeline

## Project Overview

This project aims to build a basic data pipeline using BMW global sales data to understand how raw data can be ingested, structured, and stored for further analysis.

The pipeline focuses on transforming raw CSV data into a structured database format while ensuring data integrity and preventing duplication.

**This project is currently in progress.**
**The current implementation includes raw ingestion and SQL-based transformation tables.**

---

## What I Built

- Extracted data from CSV using Python
- Loaded data into a relational database
- Designed a raw data table with constraints to ensure data quality
- Built SQL-based aggregation and feature tables for downstream analysis
- Added a pipeline entry point to run ingestion and transformations in sequence
- Documented the current data model and ERD

---

## Pipeline Flow

> bmw_global_sales_2018_2025.csv
> -> Extract (Python / Pandas)
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

---

## Project Structure

- `run_pipeline.py`: runs raw ingestion and SQL transformations
- `scripts/ingesting.py`: loads CSV files from `datas/new` into `bmw_sales_raw`
- `sql/`: contains SQL files that create aggregation and feature tables
- `docs/data_model.md`: documents the current table structure, grain, and lineage
- `docs/ERD/ERD.dbml`: source ERD definition
- `docs/ERD/ERD.png`: rendered ERD image

---

## Key Learnings

**(To be updated after project completion)**

---

## Limitations

**(To be updated after project completion)**

---

## Future Improvements

**(To be updated after project completion)**

---
