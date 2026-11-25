-- Intermediate table with exclusions applied: Floor area ≤ 9 or null; over 2,000 m² with ≤ 7 habitable rooms (or rooms missing); efficiency over 110 and consumption over 200 for flats and maisonettes; raw age band under 4 characters

CREATE OR REPLACE VIEW `intermediate.int_sales_filtered` AS

WITH source AS(
  SELECT *
  FROM `intermediate.int_sales_presale_epc`
),

exclusions AS(
  SELECT unique_id
  FROM
    source
  WHERE total_floor_area <= 9 OR total_floor_area IS NULL

  UNION ALL

  SELECT
    unique_id
  FROM
    source
  WHERE total_floor_area > 2000 AND (number_habitable_rooms <= 7 OR number_habitable_rooms IS NULL)

  UNION ALL

  SELECT
    unique_id,
  FROM
    source
  WHERE current_energy_efficiency > 110 AND energy_consumption_current > 200 AND (property_type_epc IN ('Flat', 'Maisonette'))

  UNION ALL

  SELECT
    unique_id,
  FROM
    source
  WHERE LENGTH(construction_age_band_raw) < 4
)

SELECT *
FROM
  source
LEFT JOIN exclusions e USING (unique_id)
WHERE e.unique_id IS NULL;

