-- Staging for data from match table: Trims text, nulls any empty strings, no rows removed.

CREATE OR REPLACE VIEW `staging.stg_match_table` AS
WITH source AS(
  SELECT *
  FROM `raw.match_table`
),

cleaned AS(
  SELECT
    NULLIF(TRIM(unique_id), '') AS unique_id,
    NULLIF(TRIM(certificate_number), '') AS certificate_number
  FROM
    source
)

SELECT
  unique_id,
  certificate_number
FROM cleaned;