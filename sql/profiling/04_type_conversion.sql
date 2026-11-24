
-- deed_date is in format YYYY-MM-DD
SELECT
  DISTINCT deed_date
FROM
  `raw.price_paid`
LIMIT 10

-- deed_date is always 10 characters long
SELECT DISTINCT
  LENGTH(deed_date) AS deed_date_length
FROM
  `raw.price_paid`

-- inspection_date and lodgement_date are in format YYYY-MM-DD
SELECT
  inspection_date,
  lodgement_date
FROM
  `raw.epc`
LIMIT 10

-- inspection_date and lodgement_date are always 10 characters long
SELECT
  DISTINCT LENGTH(inspection_date) AS inspection_date_length,
  LENGTH(lodgement_date) AS lodgement_date_length
FROM
  `raw.epc`



-- Checking all values convert
-- price_paid casts to INT64 and deed_date parses with no failures
SELECT
  COUNTIF(price_paid IS NOT NULL AND SAFE_CAST(price_paid AS INT64) IS NULL) AS price_paid_fail,
  COUNTIF(deed_date IS NOT NULL AND SAFE.PARSE_DATE('%F', deed_date) IS NULL) AS deed_date_fail
FROM
  `raw.price_paid`

-- No failures in conversion. Chose FLOAT64 for the fields that contain any decimals
SELECT
  COUNTIF(total_floor_area IS NOT NULL AND SAFE_CAST(total_floor_area AS INT64) IS NULL) AS total_floor_area_fail,
  COUNTIF(current_energy_efficiency IS NOT NULL AND SAFE_CAST(current_energy_efficiency AS INT64) IS NULL) AS current_energy_efficiency_fail,
  COUNTIF(heating_cost_current IS NOT NULL AND SAFE_CAST(heating_cost_current AS FLOAT64) IS NULL) AS heating_cost_current_fail,
  COUNTIF(energy_consumption_current IS NOT NULL AND SAFE_CAST(energy_consumption_current AS FLOAT64) IS NULL) AS energy_consumption_current_fail,
  COUNTIF(floor_height IS NOT NULL AND SAFE_CAST(floor_height AS FLOAT64) IS NULL) AS floor_height_fail,
  COUNTIF(inspection_date IS NOT NULL AND SAFE.PARSE_DATE('%F', inspection_date) IS NULL) AS inspection_date_fail,
  COUNTIF(lodgement_date IS NOT NULL AND SAFE.PARSE_DATE('%F', lodgement_date) IS NULL) AS lodgement_date_fail
FROM
  `raw.epc`