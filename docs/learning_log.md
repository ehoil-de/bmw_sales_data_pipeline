# Learning Log

---

## [2026-03-23] Schema broken when using `to_sql(..., if_exists="replace")`

### Trigger

While building a data pipeline, I used `pandas.to_sql()` with `if_exists="replace"` to refresh an existing table with new data.

### Problem

After loading the data, I noticed that the entire table schema had changed unexpectedly.
This was not just a data update — the table structure itself was broken.

### Root Cause

The issue comes from how `if_exists="replace"` works internally:

> It does NOT overwrite data.
> It performs: `DROP TABLE` -> `CREATE TABLE` -> `INSERT DATA`

As a result:

- The original schema defined in the database is completely removed
- A new table is created based on pandas DataFrame dtypes
- All constraints, indexes, and type definitions are lost

### Fix

Switched from `replace` to `append`:

```Python
df.to_sql(
    name="table_name",
    con=engine,
    if_exists="append",
    index=False
)
```

If a full refresh is needed:

- Explicitly run TRUNCATE TABLE or DELETE
- Then use append to preserve schema integrity

### Insight

This incident highlights an important principle in data engineering:

- `replace` is NOT a data operation -> it is a schema-destructive operation

- In production systems:
  --Schema is a contract
  --Accidentally dropping it can lead to critical failures

---

## [2026-03-27] Duplicate rows kept accumulating during repeated pipeline runs

### Trigger

While testing the pipeline, I ran it multiple times to check whether the flow worked correctly end to end.

### Problem

After checking the database, I found that the same data had been loaded repeatedly.
The more times I ran the pipeline, the more duplicated rows accumulated in the table.

### Root Cause

At first, I tried to block duplicates using a primary key.
However, this caused the pipeline to fail during execution whenever duplicate rows appeared.

The reason was that primary keys and constraints do not silently skip duplicate rows.
When duplicate data reaches the insert step, the database rejects the conflicting rows and the execution stops with an error.

### Fix

I added two defensive steps before loading data:

- First, use `drop_duplicates()` to remove duplicate rows inside the source CSV data itself
- Second, use `pandas.merge()` to compare incoming data with existing database records and filter out rows that already exist

This created a two-layer defense before insertion.

### Insight

This incident highlighted an important principle in data engineering:

- Removing duplicate data before insertion is important for pipeline stability
- Primary keys and constraints are important, but they act as a final line of defense
- If duplicate rows reach the database insert step, the execution itself can fail
- A stable pipeline needs an earlier preventive layer, such as `drop_duplicates()` for source-level duplicates and `pandas.merge()` for database-level duplicate checks

---

## [2026-03-27] Raw tables should preserve source data before cleaning

### Trigger

While loading data into the raw table with the existing duplicate-prevention logic, I noticed something unexpected.
The total number of rows in the source CSV file did not match the number of rows stored in the database.

At first, this seemed acceptable because some preprocessing had already been applied.
But after thinking about it more carefully, I realized that I could not always know in advance which rows might become useful later.
That made me feel that I needed a more reliable way to preserve the original source data first.

### Problem

The raw table was no longer acting as a true source-preserving layer.
Because too much filtering or restriction happened before or during raw loading, some original data could be lost before I had a chance to examine or clean it properly.

### Root Cause

The root cause was that the raw table had become too restrictive.
By applying strong constraints and early filtering at the raw stage, I was making data-quality decisions too soon.

This created a risk that source data would be removed before the cleaning step, even though some of that data might still be useful later for validation, auditing, or redesigning transformation logic.

### Fix

I changed the pipeline structure so that the raw table can accept as much source data as possible.
Instead of relying on the raw table to enforce strict filtering, I moved the cleaning responsibility to a separate clean table.

The updated idea is:

- load source data into `bmw_sales_raw` as completely as possible
- create `bmw_sales_clean` as a separate cleaning/staging step
- use the clean table as the base for downstream aggregation and feature tables

### Insight

This incident highlighted an important principle in data engineering:

- A raw table should preserve source data as much as possible
- Cleaning and business-rule decisions should happen after ingestion, not too early during loading
- If constraints are too strong at the raw stage, source data can be lost before it is properly analyzed
- A better structure is to ingest first, then stage/clean, and then build meaningful downstream tables

### Improvement Point

- To preserve source data in the raw table, I removed the earlier first-line defenses using `drop_duplicates()` and `pandas.merge()`, which means a different duplicate-handling strategy will be needed later.

---

## [2026-04-01] Clean tables should not remove too much usable data

### Trigger

While reviewing the tables in the database to rethink the duplicate-handling strategy, I noticed that a large amount of data was still disappearing during the cleaning step.

### Problem

The existing `WHERE`-based cleaning logic removed too many rows.
Even after moving filtering from the raw table to the clean table, the result still felt too similar to the earlier approach where too much source data was lost.

### Root Cause

The root cause was that I was still treating the clean table mainly as a filtering layer.
This meant that rows containing imperfect values were often removed entirely, even when some of their columns could still be usable for downstream analysis.

### Fix

I changed the clean-table logic so that it does not depend only on strict `WHERE` filtering.
Instead, if a row still contains enough usable information, invalid values are converted to `NULL` with `CASE WHEN` rather than removing the whole row.

The updated idea is:

- keep strict `WHERE` conditions only for values that are truly required
- preserve as many rows as possible in the clean table
- use `CASE WHEN` to replace invalid values with `NULL`
- allow downstream tables to use partially cleaned but still meaningful data

### Insight

This incident highlighted an important principle in data engineering:

- A clean table is not just a table that removes bad rows
- If data is still usable, it can be better to preserve the row and handle invalid values at the column level
- Over-filtering can create unnecessary data loss
- A better clean layer tries to balance data quality and data preservation

### Improvement Point

- I still have not found a satisfying duplicate-handling strategy, so this part of the pipeline needs more work.

---

## [2026-04-01] Clean tables needed their own duplicate-handling strategy

### Trigger

After introducing the clean table to preserve more source data in the raw layer, the earlier duplicate-prevention logic was removed.
That created a new problem: if duplicate rows appeared, the clean-table creation step could fail before downstream processing even started.

### Problem

In the current structure, duplicate rows could cause an error when building the clean table.
This meant I needed to rebuild a first line of defense against duplicates before the pipeline reached that step.

At the same time, the existing `DROP` + `CREATE` pattern was not a good fit for handling duplicates in a controlled way.

### Root Cause

The root cause was that I was still relying too much on the earlier full-rebuild pattern.
Because I learned `DROP` + `CREATE` first, I kept trying to solve the problem inside that structure even when it no longer matched the needs of the pipeline.

Once the raw table was changed to preserve more source data, the clean layer needed its own way to handle duplicate rows more safely.

### Fix

I decided to create the clean table directly in the database and rebuild the loading logic around an UPSERT-style approach.
Instead of recreating the clean table each time, the clean layer now has its own table structure and handles duplicate rows during insertion.

The updated idea is:

- keep `bmw_sales_raw` as the source-preserving table
- prepare `bmw_sales_clean` in the database as a separate table
- load cleaned rows into `bmw_sales_clean`
- use duplicate-handling logic during insertion
- let aggregation tables apply stricter row-level constraints for analytical use

### Insight

This incident highlighted an important principle in data engineering:

- `DROP` + `CREATE` is simple, but it is not always the best structure for duplicate handling
- As pipelines become more layered, each layer may need its own data-management strategy
- UPSERT-style logic can be a better fit when a table must preserve structure while preventing duplicate inserts
- Depending on the use case, `UPSERT` or `INSERT ... ON CONFLICT ...` can be more practical than full rebuilds

### Improvement Point

- While updating the tables, I noticed that even after deleting rows from the clean table, rows in the aggregation tables still remained. This needs to be solved because stale aggregated data could become risky when invalid rows are removed from upstream tables.

---

## [2026-04-05] Upstream changes needed a full-refresh strategy to stay aligned downstream

### Trigger

While reviewing the current pipeline structure, I noticed that changes in upstream tables were not always reflected clearly in downstream aggregation and feature tables.

This became more important after I had already separated the raw, clean, and derived layers.
Even though the layered structure was clearer than before, I realized that structure alone was not enough to keep downstream results aligned with upstream changes.

### Problem

In the current structure, if upstream data changed, downstream tables could still keep results based on older data.
This created a risk that aggregated or feature-level outputs would no longer match the latest clean-table state.

That meant the pipeline could appear to run successfully while still leaving stale analytical results in downstream tables.

### Root Cause

The root cause was that I was thinking mainly about table structure, but not enough about refresh strategy.

I had already improved the table design by separating raw, clean, and downstream layers.
However, I had not fully aligned the execution strategy with the purpose of those layers.

The clean table and downstream analytical tables are not meant to behave like permanent append-only storage.
They are meant to represent the current transformed state of the upstream data.

### Fix

I changed the pipeline so that the clean and downstream tables now follow a full-refresh pattern while keeping their table structures in the database.

Instead of recreating the tables themselves each time, the updated idea is:

- keep `bmw_sales_raw` as the append-based source-preserving layer
- truncate `bmw_sales_clean` and reload it from `bmw_sales_raw`
- truncate downstream aggregation and feature tables and reload them from `bmw_sales_clean`
- keep table definitions separate from refresh logic

This keeps the schema stable while allowing the table contents to be rebuilt from the latest upstream state on each pipeline run.

### Insight

This incident highlighted an important principle in data engineering:

- A layered table structure is not enough by itself
- Each layer also needs a refresh strategy that matches its purpose
- For analytical derived tables, stale data is often a refresh problem rather than a foreign-key problem
- Keeping table structure and table refresh logic separate can make the pipeline easier to reason about

### Improvement Point

- The current clean-layer duplicate handling still depends on `INSERT ... ON CONFLICT DO NOTHING`, so a clearer deduplication rule may still be needed later.
- Database initialization is now separated into project-managed SQL, but the pipeline execution flow can still be improved so setup and runtime behavior are more tightly connected.

---
