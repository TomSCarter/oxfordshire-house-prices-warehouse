-- Check total row count and for nulls in either column
SELECT 
  COUNT(*) AS total_rows,
  COUNTIF(unique_id IS NULL) AS null_unique_id,
  COUNTIF(certificate_number IS NULL) AS null_certificate_number
FROM 
  `staging.stg_match_table`;