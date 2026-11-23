-- Check that all unique_id in match table is featured in price_paid. All found, 0 unmatched IDs
SELECT
  COUNT(*) AS missing_in_price_paid
FROM
  `raw.match_table` m
LEFT JOIN `raw.price_paid` p ON m.unique_id = p.unique_id
WHERE p.unique_id IS NULL;


-- Check that all certificate_number values are found in the epc database. All found, 0 unmatched IDs
SELECT
  COUNT(*) AS missing_in_epc
FROM
  `raw.match_table` m
LEFT JOIN `raw.epc` e ON m.certificate_number = e.certificate_number
WHERE e.certificate_number IS NULL