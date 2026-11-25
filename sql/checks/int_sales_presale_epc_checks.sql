-- Check row count is 114,490 and all unique sales, correct
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT unique_id) AS unique_sales
FROM
  `intermediate.int_sales_presale_epc`