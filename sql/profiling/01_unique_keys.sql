
-- Compares unique unique_id values with total rows in the price paid dataset. Number of distinct unique_id equal to total rows, unique_id is a unique identifier (135,557 rows). 
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT unique_id) AS distinct_ids
FROM raw.price_paid;

-- Compares unique certificate_number values with total rows in the EPC dataset. Number of distinct certificate_number equal to total rows, certificate_number is a unique identifier (338,323 rows)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT certificate_number) AS distinct_ids
FROM raw.epc;

-- Compares unique rows with total rows, ensuring there is no duplication in the match table. All rows are unique (unique rows = total rows) and there are no NULLs (CONCAT would return NULL) (171,240 rows)
SELECT
  COUNT(*) AS all_rows
  COUNT(DISTINCT(CONCAT(unique_id, '|', certificate_number))) AS unique_rows,
FROM raw.match_table;