-- Check total row count and that count of null age_bands equals count of null sort_order. Returns total_rows (338,323), age_band_null (23), age_band_sort_order_null (23)
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(construction_age_band IS NULL) AS age_band_null,
  COUNTIF(construction_age_band_sort_order IS NULL) AS age_band_sort_order_null
FROM
  `staging.stg_epc`;


-- Check that NULL and invalid construction_age_band_raw values are NULL. Returns: NULL (14), 2081 (5), 201 (3), 2104 (1)
SELECT
  construction_age_band_raw,
  COUNT(*)
FROM
  `staging.stg_epc`
WHERE construction_age_band IS NULL
GROUP BY construction_age_band_raw;

-- Check number of bands and correct sort orders mapped, with check that only a single sort order is matched with each. 11 bands and NULL with correct orders
SELECT
  construction_age_band,
  AVG(construction_age_band_sort_order),
  COUNT(DISTINCT construction_age_band_sort_order)
FROM
  `staging.stg_epc`
GROUP BY construction_age_band
ORDER BY AVG(construction_age_band_sort_order);

-- No floor_heights under 1.5m
SELECT
  COUNT(*)
FROM
  `staging.stg_epc`
WHERE floor_height < 1.5;