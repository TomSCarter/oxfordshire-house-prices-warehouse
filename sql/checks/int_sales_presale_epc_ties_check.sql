-- Check for presale EPC ties

WITH source AS(
  SELECT *
  FROM `intermediate.int_matches_unambiguous`),

add_inspection_to_sale AS(
SELECT
  *,
  DATE_DIFF(deed_date, inspection_date, DAY) AS inspection_to_sale
FROM
  source
),

ranked AS(
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY unique_id ORDER BY inspection_to_sale ASC, lodgement_date DESC) AS epc_row_num,
    RANK() OVER(PARTITION BY unique_id ORDER BY inspection_to_sale ASC, lodgement_date DESC) AS epc_rank
  FROM
    add_inspection_to_sale
  WHERE inspection_to_sale >= 0
)

SELECT
  unique_id,
  inspection_to_sale,
  lodgement_date,
  COUNT(*) AS count,
  STDDEV(total_floor_area)
FROM ranked
WHERE epc_rank = 1
GROUP BY   unique_id,
  inspection_to_sale,
  lodgement_date
HAVING COUNT(*) > 1 AND COUNT(DISTINCT total_floor_area) = 1;