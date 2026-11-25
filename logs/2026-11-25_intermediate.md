# 2026-11-25: Intermediate layer

## Done
- Built `stg_match_table` and `stg_match_table_checks`
    - Just trim, nullif empty (not expected but consistent with other staging views)
    - Passes row count and no nulls
- Built `int_match_pairs` and `int_match_pairs_checks`
    - Joins raw datasets (price paid and epc) onto match table
    - Passes row count
- Built `int_match_unambiguous` and `int_match_unambiguous_checks`
    - Checks for sales matched to >1 uprn and drops them (not counting null uprn's)
    - Passes row count and unique sales count 
- Built `int_sales_presale_epc` and `int_match_presale_epc_checks`
    - Filters any EPCs with inspection_date after sale (deed_date), then ranks by how soon before the sale they were inspected, then by most recent lodgement_date
    - Passes row count
- Built `int_sales_filtered` and `int_sales_filtered_checks`
    - Removes 60 on low or null floor_area, 3 on high floor area with low rooms, 3 on too few characters in construction age band
    - Passes row count
    - My UNION ALL method of collating exclusions is NULL-safe, where a single WHERE NOT (rule or rule2...) would drop the row if any of the rules evaluated to NULL

## Decisions
- Separated initial join to match table from dropping ambiguous matches, for clarity
- Added certificate_number as a 3rd tie-break in the ranking in int_sales_presale_epc, for rare situation in which inspection_date_to_sale and lodgement_date tie


## Problems and surprises
- Initially used lodgement_date for the int_sales_presale_epc gap calculation, which gave the wrong row count
- total_floor_area <= 9 does not catch NULLs as in pandas, so had to add explicit rule
- NOT IN (query returning unique_ids) would return no rows at all if there was a single NULL unique_id. Switched to anti-join (LEFT JOIN excluded ... WHERE excluded.unique_id IS NULL)

## Learned
- int_match_unambiguous: Rather than listing 38 columns in final SELECT on joined tables, used 'SELECT *' with 'WHERE unique_id IN (subquery with list of unique_ids)'
- BigQuery has QUALIFY that can be used to filter on a window function within the same query, chose not use it as I think it'd confuse me in the future (when not working in BQ)


## Next
