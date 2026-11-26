-- Checks on dim_date: total_rows = 4018 (11 x 365 + 3 leap days), date is unique (distinct_date_count = 4018), min = 2015-01-01, max = 2025-12-31
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT date) AS distinct_date_count,
  MIN(date) AS min_date,
  MAX(date) AS max_date
FROM `marts.dim_date`;

-- Anti-join with stg_price_paid shows zero deed_date missing from dim_date
SELECT
  COUNT(*) AS dates_missing_from_dim_date
FROM `staging.stg_price_paid` p 
LEFT JOIN `marts.dim_date` d ON d.date = p.deed_date
WHERE d.date IS NULL;