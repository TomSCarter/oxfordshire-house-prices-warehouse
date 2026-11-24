-- CATEGORIES

-- Check the categories in Price Paid table. No issues: no placeholders, mixed spellings etc
SELECT
  'property_type' AS column_name,
  property_type AS value,
  COUNT(*) AS n
FROM
  `raw.price_paid`
GROUP BY property_type

UNION ALL

SELECT
  'new_build',
  new_build,
  COUNT(*)
FROM
  `raw.price_paid`
GROUP BY new_build

UNION ALL

SELECT
  'estate_type',
  estate_type,
  COUNT(*)
FROM
  `raw.price_paid`
GROUP BY estate_type

UNION ALL

SELECT
  'transaction_category',
  transaction_category,
  COUNT(*)
FROM
  `raw.price_paid`
GROUP BY transaction_category

UNION ALL

SELECT
  'district',
  district,
  COUNT(*)
FROM
  `raw.price_paid`
GROUP BY district

ORDER BY column_name, n DESC


-- Check categories in EPC table.
-- built_form - null = 6570, Not Recorded = 1305
-- construction_age_band - 94 different categories inc
    -- YYYY years
    -- Text descriptions (England and Wales: 2022 onwards (10), England and Wales: 2012-2021 (761), England and Wales: 1950-1966 (47457), England and Wales: 1967-1975 (36223), England and Wales: before 1900 (29319), England and Wales: 1983-1990 (25457), England and Wales: 1930-1949 (23229), England and Wales: 1900-1929 (20028), England and Wales: 1976-1982 (19565), England and Wales: 1996-2002 (18670), England and Wales: 1991-1995 (15912), England and Wales: 2003-2006 (13641), England and Wales: 2007-2011 (5835), England and Wales: 2012 onwards (3152), England and Wales: 2007 onwards (2776))
    -- ranges (1991-1995 (1046), 1930-1949 (1162), 1976-1982 (1213), 1996-2002 (1262), 1900-1929 (1455), 2003-2006 (1463), 1967-1975 (1825), 1983-1990 (1887), 1950-1966 (2117), Pre-1900 (2455)). 
    -- 201 (3), 2104 (1) null (14), Post-2006 (542)
-- current_energy_rating - all fine
-- property_type - null = 7
-- tenure 
    -- null = 85377, unknown = 38802, Unknown = 631, 
    -- mixed capitalisation: owner-occupied / Owner-occupied, rented (private) / Rented (private), rented (social) / Rented (social)
-- transaction_type
    -- mixed capitalisation: Marketed sale / marketed sale, new dwelling / New dwelling, non-marketed sale / Non-marketed sale, not sale or rental
    -- mixed specificity: Rental / rental (private) / rental (social), Grant scheme / Non-grant scheme
    -- null = 509, not recorded = 10
SELECT
  'current_energy_rating' AS column_name,
  current_energy_rating AS value,
  COUNT(*) AS n
FROM
  `raw.epc`
GROUP BY current_energy_rating

UNION ALL

SELECT
  'property_type',
  property_type,
  COUNT(*)
FROM
  `raw.epc`
GROUP BY property_type

UNION ALL

SELECT
  'built_form',
  built_form,
  COUNT(*)
FROM
  `raw.epc`
GROUP BY built_form

UNION ALL

SELECT
  'tenure',
  tenure,
  COUNT(*)
FROM
  `raw.epc`
GROUP BY tenure

UNION ALL

SELECT
  'construction_age_band',
  construction_age_band,
  COUNT(*)
FROM
  `raw.epc`
GROUP BY construction_age_band

UNION ALL

SELECT
  'transaction_type',
  transaction_type,
  COUNT(*)
FROM
  `raw.epc`
GROUP BY transaction_type

ORDER BY column_name, n DESC