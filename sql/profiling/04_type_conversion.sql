
-- deed_date is in format YYYY-MM-DD
SELECT
  DISTINCT deed_date
FROM
  `raw.price_paid`
LIMIT 10

-- deed_date is always 10 characters long
SELECT DISTINCT
  LENGTH(deed_date) AS deed_date_length
FROM
  `raw.price_paid`

-- inspection_date and lodgement_date are in format YYYY-MM-DD
SELECT
  inspection_date,
  lodgement_date
FROM
  `raw.epc`
LIMIT 10

-- inspection_date and lodgement_date are always 10 characters long
SELECT
  DISTINCT LENGTH(inspection_date) AS inspection_date_length,
  LENGTH(lodgement_date) AS lodgement_date_length
FROM
  `raw.epc`