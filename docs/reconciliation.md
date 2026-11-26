# Reconciliation: pandas pipeline vs BigQuery SQL

The SQL warehouse rebuilds the pipeline's downstream steps (everything after
address matching) and reproduces its row counts at every step.

Source of pipeline figures: the Land Registry cleaning pipeline's run report for
the v3 processed data (appendix below).

## Row counts by step

| Pipeline step | SQL model | Pipeline | SQL | Match |
|---|---|---|---|---|
| `load.read_price_paid` | `raw.price_paid` / `stg_price_paid` | 135,557 | 135,557 | ✓ |
| `load.read_epc` | `raw.epc` / `stg_epc` | 338,323 | 338,323 | ✓ |
| `load.filter_local_authorities` | not rebuilt (see differences) | 338,318 | — | — |
| Address matching (`merge_on_postcode`, `filter_subset_matches`) | stays in Python; exported as `raw.match_table` | 171,240 | 171,240 | ✓ |
| Joining sale and certificate attributes | `int_match_pairs` | — | 171,240 | ✓ (no fan-out) |
| `match.drop_ambiguous_matches` | `int_matches_unambiguous` | 164,823 rows / 118,222 sales | 164,823 / 118,222 | ✓ |
| `match.select_presale_epc` | `int_sales_presale_epc` | 114,490 | 114,490 | ✓ |
| `clean.apply_exclusions` | `int_sales_filtered` | 114,424 | 114,424 | ✓ |

## Exclusions breakdown (114,490 → 114,424, 66 sales)

| Rule | Sales excluded |
|---|---|
| Floor area ≤ 9 m² or null | 60 |
| Floor area > 2,000 m² with ≤ 7 habitable rooms (or rooms missing) | 3 |
| Construction age band under 4 characters (raw value) | 3 |
| Efficiency > 110 and consumption > 200 for flats/maisonettes | 0 |
| **Total** | **66** |

## Deliberate differences from the pipeline

- **Local authority filter not rebuilt.** The pipeline removed 5 EPC records
  outside the five Oxfordshire authorities (338,323 → 338,318) before matching.
  The match table was produced after that filter, so it doesn't affect the
  counts above. `stg_epc` still contains those 5 records; filter them if
  `dim_certificate` is ever built from all certificates.
- **Tie-break.** `int_sales_presale_epc` adds `total_floor_area` then `certificate_number` as third/fourth
  sort keys after inspection-to-sale gap and lodgement date, so exact EPC ties are
  settled the same way on every run. Floor area means main houses are more likely to be chosen over annexes. 
  333 sales have two or more certificates tied on inspection-to-sale gap and lodgement date. The pipeline settled these arbitrarily. Remaining column-level null differences (tenure, floor height, heated rooms, each ±1 after rule fixes) fall within this set.
- **Floor height imputation not reproduced.** The pipeline fills 2,516 missing
  floor heights with the median (`clean.impute_floor_height`). The warehouse
  leaves them NULL; imputation is an analysis choice, and no current output
  uses floor height.
- **Extra quality flags.** `is_suspect_inspection_date` (before 1 Aug 2007) and
  `is_suspect_floor_height` (> 20 m) are added in staging. Flags only; no values
  or rows are changed.
- **Construction age band harmonised** into 11 bands via
  `reference.construction_age_band_map` and a build-year rule. The raw value is
  kept as `construction_age_band_raw`, so the exclusion rule above matches the
  pipeline.
- **Address fields dropped** from staging onwards (data minimisation).
- **Tenure 'Unknown'** missed in pipeline (only 'unknown' caught), converted to NULL in `int_sales_presale_epc` giving an additional 174 NULL values.
  - raw.epc joined to `int_sales_presale_epc` and grouped on tenure shows 174 'Unknown' (and 21893 'unknown'), confirming the source

## Not yet reconciled

Column-level null counts after `clean.nullify_invalid_values` (pipeline: floor
height 2,575, tenure 35,004, heated rooms 32,426, built form 2,507). To compare
against the marts once they're built.

## Appendix: pipeline run report (v3)
 
```
                               step     rows  unique_sales  col_count  expired  floor_height_nulls  tenure_nulls  number_heated_rooms_nulls  built_form_nulls  imputed_count
0              load.read_price_paid   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
1                     load.read_epc   338323           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
2     load.filter_local_authorities   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
3   epc: normalise.strip_whitespace   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
4      epc: normalise.remove_commas   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
5      epc: normalise.build_address   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
6       epc: normalise.build_tokens   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
7    pp: normalise.strip_whitespace   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
8       pp: normalise.remove_commas   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
9       pp: normalise.build_address   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
10       pp: normalise.build_tokens   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
11          match.merge_on_postcode  4272749           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
12      match.filter_subset_matches   171240      119532.0        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
13       match.select_match_columns   171240           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
14                 save.match_table   171240           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
15     match.drop_ambiguous_matches   164823      118222.0        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
16         match.select_presale_epc   114490           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
17       match.select_final_columns   114490           NaN       36.0      NaN                 NaN           NaN                        NaN               NaN            NaN
18        features.add_epc_age_band   114490           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
19        features.add_expired_flag   114490           NaN        NaN   1151.0                 NaN           NaN                        NaN               NaN            NaN
20   features.add_calendar_features   114490           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
21     clean.nullify_invalid_values   114490           NaN        NaN      NaN              2575.0       35004.0                    32426.0            2507.0            NaN
22           clean.apply_exclusions   114424           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
23        clean.impute_floor_height   114424           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN         2516.0
24                save.save_parquet   114424           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
```

# 