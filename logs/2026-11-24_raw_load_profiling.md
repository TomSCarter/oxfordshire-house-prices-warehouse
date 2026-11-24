# 2026-11-24: Profiling finished, staging layer built

## Done
- Profiling queries in `sql/profiling/`:
    - `04_type_conversion.sql`
        - All dates are YYYY-MM-DD (0 failures with `PARSE_DATE('%F')`) 
        - price_paid, total_floor_area, current_energy_efficiency, heating_cost_current, floor_height convert with 0 failures
    - `05_categories.sql`
        - Price Paid categories clean
        - EPC needs work
            - tenure and transaction_type mixed capitalisation, placeholders such as "unknown" and "Not Recorded", construction age band in several overlapping formats
    - `06_ranges.sql`
        - category B prices from £100 to £414m
        - inspection dates back to 2000 (EPCs began in August 2007)
        - floor area 0 (2 rows)
        - floor height 0–204 m
- Wrote `docs/staging_rules.md`, split into staging (value cleaning, all rows kept) and intermediate (row exclusions copying the pipeline's THRESHOLDS)
- Built `seeds/construction_age_band_map.csv` (raw value → band + sort order) and loaded it to `reference.construction_age_band_map`
- Created the `staging` dataset and two views:
    - `stg_price_paid`
        - trim, empty → NULL, types
        - address fields dropped, 135,557 rows, 442 NULL postcodes
    - `stg_epc`
        - steps for cleaning, standardising, converting types, validating and banding
        - 338,323 rows
- Checks in `sql/checks/stg_epc_checks.sql`
    - row count
    - NULL construction age bands = NULL sort orders (23)
    - 11 construction age bands
    - no floor heights under 1.5 m

## Decisions
- Staging changes values but but never removes rows. Exclusions happen in
  intermediate (after choosing the pre-sale certificate) as in the pipeline
- Suspect values are flagged rather than nulled where the pipeline relies on
  them (`is_suspect_inspection_date`, `is_suspect_floor_height`)
- Construction age band harmonised to 11 bands. All bands from 2007 onwards
  collapsed into one "2007 onwards" (loses the 2007–2011 / 2012+ split)
- Raw age band kept as `construction_age_band_raw` so intermediate can copy
  the pipeline's "under 4 characters" exclusion
- Decision 5, data minimisation: house number/name, flat, street and locality
  dropped from staging; postcode, town, district and county kept
- Category B sales kept in the warehouse; filter in analysis where needed

## Problems and surprises
- `SAFE_CAST(current_energy_rating AS INT64)` silently turned every rating to NULL
  (the rating is a letter). `SAFE_CAST` hides mistakes, so check after casting
- `NULLIF(floor_height < 1.5, TRUE)` returned a boolean, not the height
- The year rule placed `201` in "before 1900". Fixed by computing `build_year`
  only for 4-digit values between 1500 and 2025
- Found more impossible build years: `2081` (5 certificates) and `2104` (1)
- Fan-out: joining the sort order on `age_band` (not unique in the map) grew
  338,323 rows to 965,891. Fixed by joining to the distinct (band, sort order) pairs

## Learned
- Staging models as views (`CREATE OR REPLACE VIEW`) built from CTEs, one job per step
- `UNION ALL` to stack several profiling results into one table
- `REGEXP_CONTAINS`, `DATE '...'` literals, boolean flags, `COALESCE`
- `CASE` stops at the first matching line, so order matters
- A join key must be unique on the side you join to; check the row count after
  every join (fan out risk)
- Lookup tables (dbt seeds) are better than long `CASE` statements for mappings

## Next
- `stg_match_table`
- Intermediate layer: ambiguity filter (target 164,823 rows / 118,222 sales),
  then the pre-sale certificate choice (114,490), then exclusions (114,424)