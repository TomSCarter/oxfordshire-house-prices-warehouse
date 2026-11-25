-- Intermediate table with unambiguous matched pairs. Drops sales matched to more than 1 uprn (not counting null uprn values, as in the pipeline)

CREATE OR REPLACE VIEW `intermediate.int_matches_unambiguous` AS

WITH source AS(
  SELECT *
  FROM `intermediate.int_match_pairs`
),

grouped AS(
  SELECT
    unique_id,
  FROM
    source
  GROUP BY unique_id
  HAVING COUNT(DISTINCT uprn) <= 1
)

SELECT *
FROM
  source
WHERE unique_id IN (SELECT * FROM grouped)
