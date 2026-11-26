-- Checks on fact_sales: total_rows = 135,557, distinct unique_ids = 135,557, has_certificate_count = 114,424, expired_epc_count = 1,148, property_type_null_count = 0, estate_type_null_count = 0
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT unique_id) AS unique_id_count,
  COUNTIF(has_certificate IS TRUE) AS has_certificate_count,
  COUNTIF(is_epc_expired IS TRUE) AS expired_epc_count,
  COUNTIF(property_type IS NULL) AS property_type_null_count,
  COUNTIF(estate_type IS NULL) AS estate_type_null_count
FROM
  `marts.fact_sales`;

-- Checks for certificate_numbers missing from dim_certificate (none) and deed_dates missing from dim_date (none)
SELECT
  'missing_in_dim_certificate' AS check_name,
  COUNT(*) AS check_count
FROM
  `marts.fact_sales` s
LEFT JOIN `marts.dim_certificate` c ON s.certificate_number = c.certificate_number
WHERE c.certificate_number IS NULL

UNION ALL

SELECT
  'missing_in_dim_date',
  COUNT(*) AS check_count
FROM
  `marts.fact_sales` s
LEFT JOIN `marts.dim_date` d ON s.deed_date = d.date
WHERE d.date IS NULL;



