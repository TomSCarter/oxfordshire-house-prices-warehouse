-- Intermediate table with presale EPCs only. Drops any certificates with lodgement_date after sale and keeps only those closest before the sale

CREATE OR REPLACE VIEW `intermediate.int_sales_presale_epc` AS

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
    ROW_NUMBER() OVER(PARTITION BY unique_id ORDER BY inspection_to_sale ASC, lodgement_date DESC, total_floor_area DESC NULLS LAST, certificate_number) AS epc_rank
  FROM
    add_inspection_to_sale
  WHERE inspection_to_sale >= 0
)

SELECT
  *
FROM ranked
WHERE epc_rank = 1;