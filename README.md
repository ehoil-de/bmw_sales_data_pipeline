# bmw_sales_data_pipeline

## Project Overview

This project aims to build a basic data pipeline using BMW global sales data to understand how raw data can be ingested, structured, and stored for further analysis.

The pipeline focuses on transforming raw CSV data into a structured database format while ensuring data integrity and preventing duplication.

**This project is currently in progress.**
**The current implementation includes raw ingestion and initial SQL-based transformation drafts.**

---

## What I Built

- Extracted data from CSV using Python
- Loaded data into a relational database
- Designed a raw data table with constraints to ensure data quality
- Drafted aggregation and feature-layer SQL for downstream analysis

---

## Pipeline Flow

> bmw_global_sales_2018_2025.csv
> -> Extract (Python / Pandas)
> -> Load (PostgreSQL)
> -> Transform (SQL drafts for aggregation and feature tables)

---

## Current Database Design

I designed a **bmw_sales_raw** table with constraints to maintain data integrity.

I also drafted downstream analytical tables for aggregation and feature use cases.

Key design decisions:

**NOT NULL constraints**

- Ensures essential fields are always present

**Data type constraints**

- Prevent invalid or malformed data

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
