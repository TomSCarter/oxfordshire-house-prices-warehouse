# Staging rules

- deed_date, inspection_date and lodgement_date are in the format YYYY-MM-DD (10 characters always)
- Price paid table datatypes
    - deed_date parsed as DATE (YYYY-MM-DD)
    - price_paid as INT64
- EPC table datatypes
    - total_floor_area, current_energy_efficiency as INT64 
    - heating_cost_current, energy_consumption_current as FLOAT64. Contain a handful of decimals, some are likely errors
    - floor_height as FLOAT64. Always decimal