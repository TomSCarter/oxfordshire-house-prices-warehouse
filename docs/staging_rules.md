# Staging rules

- missing values
    - Use NULLIF(TRIM(col), '') to change empty (or whitespace) strings to NULLs on all text columns
- deed_date, inspection_date and lodgement_date are in the format YYYY-MM-DD (10 characters always)
- Price paid table datatypes
    - deed_date parsed as DATE (YYYY-MM-DD)
    - price_paid as INT64
- EPC table 
    - datatypes
        - total_floor_area, current_energy_efficiency as INT64 
        - heating_cost_current, energy_consumption_current as FLOAT64. Contain a handful of decimals, some are likely errors
        - floor_height as FLOAT64. Always decimal
    - categories
        - tenure
            - lowercase everything
            - unknown/Unknown to NULL
        - transaction_type
            - lowercase everything
            - not recorded to NULL
            - Note: Contains differing levels of detail (Rental vs Rental (social) or Rental (private))
        - built_form
            - Not Recorded to NULL
        - current_energy_rating
            - No rule needed
        - construction_age_band
            - Strip prefixes: ('England and Wales: 1950-1966' to '1950-1966')
            - Merge synonyms: 'Pre-1900' = 'before 1900'
            - Single years (YYYY): Put into bands
            - Overlapping recent bands ("2007 onwards", "Post-2006", "2007-2011", "2012 onwards", "2012-2021", "2022 onwards"): Collapse into 2007 onwards. Compromise as lose detail
            - Errors (201, 2104, null): all to NULL
            - Implement by using a rule for single years into range, and a csv lookup table for the other conversions. Apply csv first to catch 2104 (into null)
    - Checking for impossible values:

        col_name	min	max	zero_count
        price_paid_cat_A	35000	18037700	0
        price_paid_cat_B	100	414108660	0
        deed_date	2015-01-02	2025-12-23	
        inspection_date	2000-10-31	2025-12-31	
        lodgement_date	2008-09-22	2025-12-31	
        total_floor_area	0	5133	2
        floor_height	0	204	209
        current_energy_efficiency	1	156	0

        - price_paid
            - transaction_category B sales have odd prices, down to £100, up to £414 million. Kept in warehouse for consistency with pipeline, filtered to cat. A in analysis where needed
        - deed_date
            - Covers expected range
            - Comparison of dates as strings worked due to YYYY-MM-DD format
        - inspection_date
            - Goes back to 2000, EPCs started on 2007-08-01. Add is_suspect_inspection_date flag to < 2007-08-01
        - lodgement_date
            - Covers expected range
        - total_floor_area
            - zero values to NULL. Will not effect reconciliation as pipeline filters to <=9
        - floor_height
            - < 1.5 to NULL. Upper limit was not in the pipeline (not needed), so could change numbers at later stages. For > 20 add is_suspect_floor_height
        - current_energy_efficiency
            - No changes needed

- For the Intermediate section (row exclusions, copying the pipeline's THRESHOLDS, applied after choosing the pre-sale certificate)
    - floor area ≤ 9 or null; > 2000 m² with ≤ 7 rooms 
    - efficiency > 110 and consumption > 200 for flats and maisonettes
    - construction age band under 4 characters (use the raw column)
    - Flags for these can be added in staging