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

## Decisions
- Separated initial join to match table from dropping ambiguous matches, for clarity


## Problems and surprises

## Learned
- int_match_unambiguous: Rather than listing 38 columns in final SELECT on joined tables, used 'SELECT *' with 'WHERE unique_id IN (subquery with list of unique_ids)'


## Next
