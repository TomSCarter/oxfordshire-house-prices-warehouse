-- Check for missing values (as NULL or empty string). postcode_empty = 442, all others zero
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(price_paid IS NULL) AS price_paid_null,
  COUNTIF(TRIM(price_paid) = '') AS price_paid_empty,
  COUNTIF(deed_date IS NULL) AS deed_date_null,
  COUNTIF(TRIM(deed_date) = '') AS deed_date_empty,
  COUNTIF(postcode IS NULL) AS postcode_null,
  COUNTIF(TRIM(postcode) = '') AS postcode_empty,
  COUNTIF(property_type IS NULL) AS property_type_null,
  COUNTIF(TRIM(property_type) = '') AS property_type_empty,
  COUNTIF(new_build IS NULL) AS new_build_null,
  COUNTIF(TRIM(new_build) = '') AS new_build_empty,
  COUNTIF(transaction_category IS NULL) AS transaction_category_null,
  COUNTIF(TRIM(transaction_category) = '') AS transaction_category_empty,
  COUNTIF(district IS NULL) AS district_null,
  COUNTIF(TRIM(district) = '') AS district_empty
FROM
  `raw.price_paid`;


-- Check for missing values (as NULL or empty string). total_floor_area_null = 339, construction_age_band_null = 14, uprn_null = 2623, tenure_null = 85,377. all others zero
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(total_floor_area IS NULL) AS total_floor_area_null,
  COUNTIF(TRIM(total_floor_area) = '') AS total_floor_area_empty,
  COUNTIF(current_energy_rating IS NULL) AS current_energy_rating_null,
  COUNTIF(TRIM(current_energy_rating) = '') AS current_energy_rating_empty,
  COUNTIF(inspection_date IS NULL) AS inspection_date_null,
  COUNTIF(TRIM(inspection_date) = '') AS inspection_date_empty,
  COUNTIF(lodgement_date IS NULL) AS lodgement_date_null,
  COUNTIF(TRIM(lodgement_date) = '') AS lodgement_date_empty,
  COUNTIF(construction_age_band IS NULL) AS construction_age_band_null,
  COUNTIF(TRIM(construction_age_band) = '') AS construction_age_band_empty,
  COUNTIF(uprn IS NULL) AS uprn_null,
  COUNTIF(TRIM(uprn) = '') AS uprn_empty,
  COUNTIF(tenure IS NULL) AS tenure_null,
  COUNTIF(TRIM(tenure) = '') AS tenure_empty
FROM
  `raw.epc`;