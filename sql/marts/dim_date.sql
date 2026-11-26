-- Calendar table: 2015-01-01 to 2025-12-31 with date, year, quarter, month, day, day_name, month_name, year_month and weekend_flag (sat/sun)

CREATE OR REPLACE TABLE `marts.dim_date` AS

SELECT 
  date,
  EXTRACT(YEAR FROM date) AS year,
  EXTRACT(QUARTER FROM date) AS quarter,
  EXTRACT(MONTH FROM date) AS month,
  EXTRACT(DAY FROM date) AS day,
  FORMAT_DATE('%a', date) AS day_name,
  CAST(FORMAT_DATE('%u', date) AS INT64) AS dayofweek_number,
  FORMAT_DATE('%b', date) AS month_name,
  FORMAT_DATE('%Y-%m', date) AS year_month,
  EXTRACT(DAYOFWEEK FROM date) IN (7, 1) AS weekend_flag 
FROM UNNEST(GENERATE_DATE_ARRAY(DATE '2015-01-01', DATE '2025-12-31', INTERVAL 1 DAY)) AS date;