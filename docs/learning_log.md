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
