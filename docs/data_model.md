# BMW Sales Data Model

## TL;DR

- Current implementation is centered on the raw layer
- Aggregation and feature tables are derived directly from the raw table
- Grain is explicitly defined per table
- The model is organized for analytics
- Lineage is preferred over heavy FK usage in derived tables

> For full physical schema (columns, data types, constraints), refer to the ERD diagram created with dbdiagram.

## Overview

This project models monthly BMW sales data to support analytical and forecasting use cases.

At the current stage of the project, the pipeline is built around a raw ingestion table and several derived analytical tables.
The model documented here reflects the current structure of the project.

The data model is used to:

- enable regional and model-level sales analysis
- integrate macroeconomic indicators (GDP, fuel prices)
- separate raw ingestion from analytical and feature layers

The current pipeline follows this layered architecture:

> Raw Layer → Aggregation Layer → Feature Layer

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
- Used as the single source of truth for all downstream transformations

### Aggregation Layer

The tables below are derived directly from `bmw_sales_raw`.

**`monthly_region_sales`**

**Purpose**

- Provides regional-level aggregated metrics for reporting and trend analysis

**Grain**

- One row per `(year, month, region)`

**Derived From**

- `bmw_sales_raw`

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

- `bmw_sales_raw`

**Transformation Logic**

- Aggregation across regions per model
- Weighted average pricing applied

**Rationale**

- Enables product-level performance comparison
- Supports model trend and lifecycle analysis

### Feature Layer

The feature tables below are analytical outputs derived directly from `bmw_sales_raw` at the current stage of the project.

**`sales_gdp_feature`**

**Purpose**

- Combines sales metrics with GDP indicators for forecasting and regression models

**Grain**

- One row per `(region, gdp_growth)`

**Derived From**

- `bmw_sales_raw`

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

- `bmw_sales_raw`

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
> monthly_region_sales
> monthly_model_sales
> sales_gdp_feature
> sales_fuel_index_feature

- `bmw_sales_raw` is the current implemented source table
- All derived tables originate from `bmw_sales_raw`
- Aggregation and feature tables are currently derived directly from the raw table

## Grain Summary

| table                    | grain                          |
| ------------------------ | ------------------------------ |
| bmw_sales_raw            | (year, month, region, model)   |
| monthly_region_sales     | (year, month, region)          |
| monthly_model_sales      | (year, month, model)           |
| sales_gdp_feature        | (region, gdp_growth)           |
| sales_fuel_index_feature | (region, fuel_price_index_low) |

## Data Quality Checks

The following rules define the expected data quality standard for the model.
These checks are centered on the current raw table and its downstream derived tables.

- No duplicate rows at raw grain `(year, month, region, model)`
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
