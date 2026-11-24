-- Check row count. 135,557 as expected
SELECT
  COUNT(*) AS total_rows
FROM
  `staging.stg_price_paid`;

-- Check NULL postcodes count
SELECT
  COUNTIF(postcode IS NULL) AS null_postcodes
FROM
  `staging.stg_price_paid`;

-- Check for NULLs in price_paid and deed_date
  SELECT
  COUNTIF(price_paid IS NULL) AS null_price_paid,
  COUNTIF(deed_date IS NULL) AS null_deed_date
FROM
  `staging.stg_price_paid`