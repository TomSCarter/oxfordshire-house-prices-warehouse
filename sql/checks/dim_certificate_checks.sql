-- Check total rows equal to distinct certificate_numbers. 98925 = 98925: Pass

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT certificate_number) AS distinct_certificate_number
FROM
  `marts.dim_certificate`;

-- Check distinct certificate_numbers in dim_certificate is equal to distinct certificate_numbers in int_sales_filtered + 1. 98925 = 98924 + 1: Pass
SELECT
  'dim_certificate distinct certificate_number' AS table_name,
  COUNT(DISTINCT certificate_number) AS total_rows
FROM
  `marts.dim_certificate`

UNION ALL

SELECT
  'int_sales_filtered distinct certificate_number',
  COUNT(DISTINCT certificate_number)
FROM
  `intermediate.int_sales_filtered`;