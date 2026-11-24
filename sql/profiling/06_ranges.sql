-- Checking for impossible values
SELECT
  'price_paid_cat_A' AS col_name,
  CAST(MIN(SAFE_CAST(price_paid AS INT64)) AS STRING) AS min,
  CAST(MAX(SAFE_CAST(price_paid AS INT64)) AS STRING) AS max,
  COUNTIF(SAFE_CAST(price_paid AS INT64) = 0) AS zero_count
FROM
  `raw.price_paid`
WHERE transaction_category = 'A'

UNION ALL

SELECT
  'price_paid_cat_B' AS col_name,
  CAST(MIN(SAFE_CAST(price_paid AS INT64)) AS STRING) AS min,
  CAST(MAX(SAFE_CAST(price_paid AS INT64)) AS STRING) AS max,
  COUNTIF(SAFE_CAST(price_paid AS INT64) = 0) AS zero_count
FROM
  `raw.price_paid`
WHERE transaction_category = 'B'

UNION ALL

SELECT
  'deed_date',
  MIN(deed_date),
  MAX(deed_date),
  NULL
FROM
  `raw.price_paid`

UNION ALL

SELECT
  'inspection_date',
  MIN(inspection_date),
  MAX(inspection_date),
  NULL
FROM
  `raw.epc`

UNION ALL

SELECT
  'lodgement_date',
  MIN(lodgement_date),
  MAX(lodgement_date),
  NULL
FROM
  `raw.epc`

UNION ALL

SELECT
  'total_floor_area',
  CAST(MIN(SAFE_CAST(total_floor_area AS FLOAT64)) AS STRING) AS min,
  CAST(MAX(SAFE_CAST(total_floor_area AS FLOAT64)) AS STRING) AS max,
  COUNTIF(SAFE_CAST(total_floor_area AS FLOAT64) = 0) AS zero_count
FROM
  `raw.epc`

UNION ALL

SELECT
  'floor_height',
  CAST(MIN(SAFE_CAST(floor_height AS FLOAT64)) AS STRING) AS min,
  CAST(MAX(SAFE_CAST(floor_height AS FLOAT64)) AS STRING) AS max,
  COUNTIF(SAFE_CAST(floor_height AS FLOAT64) = 0) AS zero_count
FROM
  `raw.epc`

UNION ALL

SELECT
  'current_energy_efficiency',
  CAST(MIN(SAFE_CAST(current_energy_efficiency AS FLOAT64)) AS STRING) AS min,
  CAST(MAX(SAFE_CAST(current_energy_efficiency AS FLOAT64)) AS STRING) AS max,
  COUNTIF(SAFE_CAST(current_energy_efficiency AS FLOAT64) = 0) AS zero_count
FROM
  `raw.epc`;
