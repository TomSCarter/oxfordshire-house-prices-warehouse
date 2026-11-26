-- Fact sales table, centre of star schema. One row per sale (135,557) with keys (unique_id, deed_date and certificate_number), measure (price_paid), sale attributes (property type, new build, estate type, transaction category, postcode, town, district, county.), match attributes (days from inspection to sale, certificate age band, is_epc_expired)

CREATE OR REPLACE TABLE `marts.fact_sales` AS

WITH joined AS (SELECT
  unique_id,
  p.deed_date AS deed_date,
  COALESCE(s.certificate_number, 'UNKNOWN') AS certificate_number,
  p.price_paid AS price_paid,
  p.postcode AS postcode,
  p.district AS district,
  p.county AS county,
  p.town AS town,
  CASE 
    WHEN p.property_type = 'D' THEN 'Detached'
    WHEN p.property_type = 'S' THEN 'Semi-detached'
    WHEN p.property_type = 'T' THEN 'Terraced'
    WHEN p.property_type = 'F' THEN 'Flat/Maisonette'
    WHEN p.property_type = 'O' THEN 'Other' --  From Land Registry guidance: "‘Other’ is only valid where the transaction relates to a property type that is not covered by existing values, for example where a property comprises more than one large parcel of land"
    END AS property_type,
  CASE
    WHEN p.new_build = 'Y' THEN TRUE
    WHEN p.new_build = 'N' THEN FALSE
    END AS is_new_build,
  CASE
    WHEN p.estate_type = 'F' THEN 'Freehold'
    WHEN p.estate_type = 'L' THEN 'Leasehold'
    END AS estate_type,
  p.transaction_category AS transaction_category,
  s.certificate_number IS NOT NULL AS has_certificate,
  DATE_DIFF(p.deed_date, s.inspection_date, DAY) AS inspection_to_sale_days,
  s.lodgement_date AS lodgement_date
FROM
 `staging.stg_price_paid` p
LEFT JOIN `intermediate.int_sales_filtered` s USING(unique_id)
)

SELECT
  unique_id,
  deed_date,
  certificate_number,
  price_paid,
  postcode,
  district,
  county,
  town,
  property_type,
  is_new_build,
  estate_type,
  transaction_category,
  has_certificate,
  inspection_to_sale_days,
  CASE
    WHEN inspection_to_sale_days IS NULL THEN NULL
    WHEN inspection_to_sale_days <= 365 THEN '0-1 years'
    WHEN inspection_to_sale_days <= 1095 THEN '1-3 years'
    WHEN inspection_to_sale_days <= 1825 THEN '3-5 years'
    WHEN inspection_to_sale_days <= 3650 THEN '5-10 years'
    ELSE '10 years+'
    END AS epc_age_band,
    deed_date > DATE_ADD(lodgement_date, INTERVAL 10 YEAR) AS is_epc_expired
FROM
 joined;
