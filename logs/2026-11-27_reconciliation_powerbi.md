# 2026-11-27: Reconciliation finished, README, Power BI

## Done
- Checked type-conversion of: `number_heated_rooms`, `number_habitable_rooms`, `extension_count` and `potential_energy_efficiency` all cast to INT64 with 0 failures (added to `04_type_conversion.sql`)
    - Explored as a possible explanation for extra null vs pipeline. Must come from pre-sale EPC selection tie-break (see reconciliation.md, second Decision)
- Rebuilt `dim_certificate` and `fact_sales` (as tables don't pick up upstream changes like the staging/intermediate views) after the tie-break and heated-rooms changes
  - `fact_sales` counts unchanged
  - `dim_certificate`: 98,926 rows (98,925 certificates + UNKNOWN)
    - One more than yesterday because the new tie-break changed which certificate some tied sales link to
- Finished `reconciliation.md`: added column-level table (expired certificates and built form NULLs match exactly, heated rooms and floor height NULLs ±1 (within number of ties), tenure +174 ('Unknown' to NULL fix))
- Updated `staging_rules.md` 
    - heated rooms 0 → NULL
    - build year range 1500–2025 
    - "or rooms missing" in the large-floor-area exclusion
- Updated `decisions.md`
    - floor-area tie-break
    - corrected the UPRN lookup note
- README brought up to date: warehouse layers, reconciliation summary with units, design decisions 1–7, reproduction steps, "How this was built"
- Checked the public repo: no postcodes, local paths or key material
- Power BI: connected to BigQuery and loaded `fact_sales`, `dim_certificate`, `dim_date`

## Decisions
- Column-level reconciliation judged complete: remaining ±1 differences are explained by the 333 tied sales, where the pipeline chose arbitrarily
- Added a "How this was built" section noting AI assistance (tutor, reviewer, documentation drafts)

## Problems and surprises
- External README review: clarified that `fact_sales` holds all 135,557 sales (114,424 with a certificate, 21,133 linked to UNKNOWN), and labelled units in the reconciliation chain.
- Renamed the seed file to `construction_age_band_map.csv` to match the table name and dbt convention

## Learned
- Marts built as tables must be rebuilt when upstream logic changes (views update automatically)
- A tie-break is a design choice that can change results, not just a technicality

## Next
- Power BI: relationships, mark `dim_date` as date table, turn off auto date/time, sort-by columns, measures (sales count, median price, median £/m²), checks against known counts and the dashboard
- `powerbi/notes.md` and a Model view screenshot for the README
- Pipeline repo history clean-up (moved to next week)