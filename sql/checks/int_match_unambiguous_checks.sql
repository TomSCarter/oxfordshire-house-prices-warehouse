-- Check row count is 164,823 and unique sales is 118222, correct
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT unique_id) AS unique_sales
FROM
  `intermediate.int_matches_unambiguous`