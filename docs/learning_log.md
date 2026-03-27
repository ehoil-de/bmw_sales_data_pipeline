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
