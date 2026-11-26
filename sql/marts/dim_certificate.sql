-- Marts table with certificate information: One row per certificate linked to a sale, plus an UNKNOWN row for sales without one.

CREATE OR REPLACE TABLE `marts.dim_certificate` AS

WITH source AS(
  SELECT *
  FROM `intermediate.int_sales_filtered`
)

SELECT DISTINCT 
  certificate_number,
  inspection_date,
  lodgement_date,
  total_floor_area,
  floor_height,
  current_energy_rating,
  current_energy_efficiency,
  energy_consumption_current,
  heating_cost_current,
  potential_energy_efficiency,
  number_habitable_rooms,
  number_heated_rooms,
  extension_count,
  built_form,
  construction_age_band,
  construction_age_band_sort_order,
  build_year,
  transaction_type,
  uprn,
  property_type_epc AS property_type,
  tenure,
  is_suspect_inspection_date,
  is_suspect_floor_height
FROM
  source

UNION ALL

SELECT
  'UNKNOWN', -- certificate_number,
  CAST(NULL AS DATE), -- inspection_date,
  CAST(NULL AS DATE), -- lodgement_date,
  CAST(NULL AS INT64), -- total_floor_area,
  CAST(NULL AS FLOAT64), -- floor_height,
  CAST(NULL AS STRING), -- current_energy_rating
  CAST(NULL AS INT64), -- current_energy_efficiency,
  CAST(NULL AS FLOAT64), -- energy_consumption_current,
  CAST(NULL AS FLOAT64), -- heating_cost_current,
  CAST(NULL AS INT64), -- potential_energy_efficiency,
  CAST(NULL AS INT64), -- number_habitable_rooms,
  CAST(NULL AS INT64), -- number_heated_rooms,
  CAST(NULL AS INT64), -- extension_count,
  CAST(NULL AS STRING), -- built_form,
  CAST(NULL AS STRING), -- construction_age_band,
  CAST(NULL AS INT64), -- construction_age_band_sort_order,
  CAST(NULL AS INT64), -- build_year,
  CAST(NULL AS STRING), -- transaction_type,
  CAST(NULL AS STRING), -- uprn,
  CAST(NULL AS STRING), -- property_type,
  CAST(NULL AS STRING), -- tenure,
  CAST(NULL AS BOOL), -- is_suspect_inspection_date,
  CAST(NULL AS BOOL); -- is_suspect_floor_height



