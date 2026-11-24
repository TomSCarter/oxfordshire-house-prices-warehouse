-- Staging for data from Price Paid: Trims text, converts empty strings to NULLs, casts types. No rows removed.
-- Address fields dropped (minimise data, can't use them due to licensing)

CREATE OR REPLACE VIEW `staging.stg_price_paid` AS
WITH source AS(
  SELECT *
  FROM raw.price_paid
),

cleaned AS(
  SELECT
    NULLIF(TRIM(unique_id), '') AS unique_id,
    NULLIF(TRIM(price_paid), '') AS price_paid,
    NULLIF(TRIM(deed_date), '') AS deed_date,
    NULLIF(TRIM(postcode), '') AS postcode,
    NULLIF(TRIM(district), '') AS district,
    NULLIF(TRIM(county), '') AS county,
    NULLIF(TRIM(town), '') AS town,
    NULLIF(TRIM(property_type), '') AS property_type,
    NULLIF(TRIM(new_build), '') AS new_build,
    NULLIF(TRIM(estate_type), '') AS estate_type,
    NULLIF(TRIM(transaction_category), '') AS transaction_category
  FROM
    source
),
typed AS(
  SELECT
    unique_id,
    SAFE_CAST(price_paid AS INT64) AS price_paid,
    SAFE.PARSE_DATE('%F', deed_date) AS deed_date,
    postcode,
    district,
    county,
    town,
    property_type,
    new_build,
    estate_type,
    transaction_category
  FROM
    cleaned
)

SELECT
  *
FROM
  typed;