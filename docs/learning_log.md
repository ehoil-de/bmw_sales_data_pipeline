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
