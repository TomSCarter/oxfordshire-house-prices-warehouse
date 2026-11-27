# 2026-11-23: Raw layer loaded, profiling started

## Done
- Wrote design decisions 3–4 in `docs/decisions.md` (fact table grain, certificate dimension)
- Created Cloud Storage bucket and uploaded the EPC CSV and the five Price Paid CSVs (all work in europe-west2)
- Wrote `load/make_schema.py` to generate all-STRING BigQuery schemas from each CSV's header row; saved `load/schema_epc.json` and `load/schema_pp.json`
- Loaded three tables into the `raw` dataset:
  - `raw.price_paid`: 135,557 rows (wildcard load of all five `ppd_data*.csv` files)
  - `raw.epc`: 338,323 rows
  - `raw.match_table`: 171,240 rows (Parquet upload)
  - All counts match the pandas pipeline
- Profiling queries in `sql/profiling/`:
  - `01_unique_keys.sql`: `unique_id`, `certificate_number` and the match-table pair are all unique and never null
  - `02_join_integrity.sql`: every ID in the match table exists in its source table (0 unmatched in both directions)
  - `03_missing_values.sql`: EPC nulls match the pandas figures exactly (floor area 339, construction age band 14, UPRN 2,623, tenure 85,377); Price Paid has 442 empty postcodes

## Decisions
- Fact table grain: one row per sale, all sales kept; unmatched sales point to an "unknown" certificate row
- `dim_certificate` keyed on `certificate_number`; no property dimension for now
- Raw tables loaded as all STRING; types will be converted in staging (where any conversion failures can be counted)

## Problems and surprises
- The 442 missing Price Paid postcodes load as empty strings (`''`), not NULL, because the CSV writes them as quoted empty fields. Pandas read them as null.
  - Staging rule: convert empty strings to NULL with `NULLIF(TRIM(...), '')`
- First empty-string checks compared against a single space (`' '`) rather than `''`, so they missed the empty postcodes. Fixed with `TRIM(col) = ''`

## Learned
- Cloud Storage buckets, and loading into BigQuery
- Table names in backticks, not quotes; don't need the project in query FROM when inside your own project
- `COUNTIF`, `COUNT(DISTINCT ...)` (ignores NULLs), `CONCAT` with a separator
- Anti-join pattern (`LEFT JOIN ... WHERE right.key IS NULL`); test the actual key, not another column that you expect to be non-null
- `TRIM(col) = ''` catches empty and whitespace-only values; `IS NULL` still needed separately

## Next
- Profiling 4–6: type conversion (`SAFE_CAST`, date formats), category values, ranges
- Start the staging layer: rename, convert types, NULLIF rule