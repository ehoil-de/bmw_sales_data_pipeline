# BMW Sales Data Model

## TL;DR

- Current implementation is centered on the raw layer
- A clean layer now sits between raw data and derived tables
- Grain is explicitly defined per table
- The model is organized for analytics
- Lineage is preferred over heavy FK usage in derived tables

> For full physical schema (columns, data types, constraints), refer to the ERD diagram created with dbdiagram.

## Overview

This project models monthly BMW sales data to support analytical and forecasting use cases.

At the current stage of the project, the pipeline is built around a raw ingestion table, a clean table, and several derived analytical tables.
The model documented here reflects the current structure of the project.

The data model is used to:

- enable regional and model-level sales analysis
- integrate macroeconomic indicators (GDP, fuel prices)
- separate raw ingestion from analytical and feature layers

The current pipeline follows this layered architecture:

> Raw Layer → Clean Layer → Aggregation Layer / Feature Layer

## Design Principles

The data model is built around the following principles:

### Layered Architecture

- Raw, aggregation, and feature layers are conceptually separated
- Each layer serves a distinct purpose
- This keeps ingestion logic separate from downstream analysis use cases

### Explicit Grain Management

- Each table has a clearly defined grain
- Aggregations are separated into their own tables
- This avoids ambiguity in metric calculations

### Feature Isolation

- Feature tables are separated from reporting marts
- This supports exploratory analytical use cases with external indicators

## Data Layers

### Raw Layer

`bmw_sales_raw`

**Purpose**

- Stores raw monthly sales data at the most granular level
- Serves as the current implemented base table of the project

**Grain**

- One row per `(year, month, region, model)`

**Characteristics**

- Source-aligned structure
- Includes both business metrics and external indicators
- Used as the source table for the clean layer

### Clean Layer

`bmw_sales_clean`

**Purpose**

- Stores filtered and cleaned sales data before downstream aggregation and feature creation
- Serves as the current transformation boundary between raw ingestion and derived tables

**Grain**

- One row per `(year, month, region, model)`

**Derived From**

- `bmw_sales_raw`

**Current Cleaning Logic**

- Preserves the raw table structure for downstream use
- Filters rows based on current quality conditions before downstream table creation

**Characteristics**

- Keeps the same business grain as the raw table
- Acts as the base table for current aggregation and feature queries

### Aggregation Layer

The tables below are derived from `bmw_sales_clean`.

**`monthly_region_sales`**

**Purpose**

- Provides regional-level aggregated metrics for reporting and trend analysis

**Grain**

- One row per `(year, month, region)`

**Derived From**

- `bmw_sales_clean`

**Transformation Logic**

- `total_units_sold = SUM(units_sold)`
- `total_revenue_eur = SUM(revenue_eur)`
- `weighted_avg_price_eur = SUM(revenue_eur) / NULLIF(SUM(units_sold), 0)`

**Rationale**

- Regional aggregation is frequently used in dashboards
- Pre-aggregation reduces query complexity and cost

**`monthly_model_sales`**

**Purpose**

- Tracks performance at the model level across all regions

**Grain**

- One row per `(year, month, model)`

**Derived From**

- `bmw_sales_clean`

**Transformation Logic**

- Aggregation across regions per model
- Weighted average pricing applied

**Rationale**

- Enables product-level performance comparison
- Supports model trend and lifecycle analysis

### Feature Layer

The feature tables below are analytical outputs derived from `bmw_sales_clean` at the current stage of the project.

**`sales_gdp_feature`**

**Purpose**

- Combines sales metrics with GDP indicators for forecasting and regression models

**Grain**

- One row per `(region, gdp_growth)`

**Derived From**

- `bmw_sales_clean`

**Example Features**

- current GDP growth
- weighted premium share
- weighted BEV share
- aggregated sales volume by GDP level

**Rationale**

- Economic conditions influence vehicle demand
- Grouping sales metrics by GDP level helps observe broad economic patterns

**`sales_fuel_index_feature`**

**Purpose**

- Captures the relationship between fuel prices and vehicle sales behavior

**Grain**

- One row per `(region, fuel_price_index_low)`

**Derived From**

- `bmw_sales_clean`

**Example Features**

- rounded fuel price index
- weighted premium share
- weighted BEV share
- aggregated sales volume by fuel price level

**Rationale**

- Fuel prices affect consumer preference for EV vs ICE vehicles
- Grouping sales metrics by fuel price level supports exploratory elasticity analysis

## Data Lineage

The current data model follows a one-directional transformation flow:

> bmw_sales_raw
> ↓
> bmw_sales_clean
> ↓
> monthly_region_sales
> monthly_model_sales
> sales_gdp_feature
> sales_fuel_index_feature

- `bmw_sales_raw` is the current implemented source table
- `bmw_sales_clean` is the current intermediate transformation table
- Aggregation and feature tables are currently derived from the clean table

## Grain Summary

| table                    | grain                          |
| ------------------------ | ------------------------------ |
| bmw_sales_raw            | (year, month, region, model)   |
| bmw_sales_clean          | (year, month, region, model)   |
| monthly_region_sales     | (year, month, region)          |
| monthly_model_sales      | (year, month, model)           |
| sales_gdp_feature        | (region, gdp_growth)           |
| sales_fuel_index_feature | (region, fuel_price_index_low) |

## Data Quality Checks

The following rules define the expected data quality standard for the model.
These checks are centered on the current raw table, clean table, and downstream derived tables.

- The clean layer is expected to preserve one row per `(year, month, region, model)` after filtering
- `units_sold >= 0`
- `revenue_eur >= 0`
- `bev_share BETWEEN 0 AND 1`
- `premium_share BETWEEN 0 AND 100`
- `month BETWEEN 1 AND 12`
- `avg_price_eur >= 0`

Additional validation:

- `revenue_eur ≈ units_sold * avg_price_eur` (tolerance allowed)
- Null values are not permitted in key dimensions

## Design Decisions & Trade-offs

### No Heavy Use of Foreign Keys

- Relationships are defined via shared grain and lineage
- Avoids unnecessary constraints in analytical workloads

### Clean Layer Introduction

- A separate clean table is used before aggregation and feature generation
- This creates a clearer transformation boundary between ingestion and downstream analysis
- The current clean table also acts as the main filtering layer for downstream data quality

### Separation of Feature Layer

- Feature tables are separated from reporting marts
- This supports independent experimentation without impacting reporting tables

### Weighted Average Pricing

- Simple averages are avoided to prevent aggregation bias
- Ensures accurate pricing metrics at aggregated levels

### Pre-Aggregation Strategy

- Frequently used metrics are materialized into separate derived tables
- This trades storage for simpler and faster analytical queries

## Analytical Use Cases

This data model supports:

- Regional sales trend analysis
- Model performance comparison
- BEV adoption tracking
- GDP vs sales correlation analysis
- Fuel price impact on EV demand
- Time-series forecasting
