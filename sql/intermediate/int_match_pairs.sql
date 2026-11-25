-- Intermediate layer matched pairs table. Joins raw data onto match_table

CREATE OR REPLACE VIEW `intermediate.int_match_pairs` AS

WITH source AS(

  SELECT *
  FROM
    `staging.stg_match_table`

),
pp_joined AS(
SELECT
  s.unique_id,
  price_paid,
  deed_date,
  postcode,
  district,
  county,
  town,
  property_type,
  new_build,
  estate_type,
  transaction_category,
  certificate_number

FROM
  source s
INNER JOIN `staging.stg_price_paid` p USING(unique_id)
),

both_joined AS(
SELECT
  p.unique_id AS unique_id,
  price_paid,
  deed_date,
  p.postcode AS postcode_pp,
  district,
  county,
  town,
  p.property_type AS property_type_pp,
  new_build,
  estate_type,
  transaction_category,
  p.certificate_number AS certificate_number,
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
  construction_age_band_raw,
  construction_age_band,
  construction_age_band_sort_order,
  build_year,
  transaction_type,
  e.postcode AS postcode_epc,
  posttown,
  local_authority,
  uprn,
  e.property_type AS property_type_epc,
  tenure,
  is_suspect_inspection_date,
  is_suspect_floor_height

FROM
  pp_joined p
INNER JOIN `staging.stg_epc` e USING(certificate_number)
)

SELECT *
FROM
  both_joined;