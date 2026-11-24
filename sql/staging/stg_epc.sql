-- Staging for data from EPC: Trims text, converts empty strings, placeholders and invalid values to NULLs, casts types, adds flags for suspect floor_height or inspection_date, adds build_year where known, standardises construction_age_band. No rows removed.

CREATE OR REPLACE VIEW `staging.stg_epc` AS
WITH source AS(
  SELECT *
  FROM raw.epc
),

cleaned AS(
  SELECT
    NULLIF(TRIM(certificate_number), '') AS certificate_number,
    NULLIF(TRIM(inspection_date), '') AS inspection_date,
    NULLIF(TRIM(lodgement_date), '') AS lodgement_date,
    NULLIF(TRIM(total_floor_area), '') AS total_floor_area,
    NULLIF(TRIM(floor_height), '') AS floor_height,
    NULLIF(TRIM(current_energy_rating), '') AS current_energy_rating,
    NULLIF(TRIM(current_energy_efficiency), '') AS current_energy_efficiency,
    NULLIF(TRIM(energy_consumption_current), '') AS energy_consumption_current,
    NULLIF(TRIM(heating_cost_current), '') AS heating_cost_current,
    NULLIF(TRIM(potential_energy_efficiency), '') AS potential_energy_efficiency,
    NULLIF(TRIM(number_habitable_rooms), '') AS number_habitable_rooms,
    NULLIF(TRIM(number_heated_rooms), '') AS number_heated_rooms,
    NULLIF(TRIM(extension_count), '') AS extension_count,
    NULLIF(TRIM(built_form), '') AS built_form,
    NULLIF(TRIM(construction_age_band), '') AS construction_age_band,
    NULLIF(TRIM(transaction_type), '') AS transaction_type,
    NULLIF(TRIM(postcode), '') AS postcode,
    NULLIF(TRIM(posttown), '') AS posttown,
    NULLIF(TRIM(local_authority), '') AS local_authority,
    NULLIF(TRIM(uprn), '') AS uprn,
    NULLIF(TRIM(property_type), '') AS property_type,
    NULLIF(TRIM(tenure), '') AS tenure
  FROM
    source
),
standardised AS(
    SELECT
        certificate_number,
        inspection_date,
        lodgement_date,
        total_floor_area,
        floor_height,
        current_energy_rating,
        current_energy_efficiency,
        energy_consumption_current,
        heating_cost_current,
        potential_energy_efficiency,
        number_habitable_rooms,
        number_heated_rooms,
        extension_count,
        NULLIF(built_form, 'Not Recorded') AS built_form,
        construction_age_band,
        NULLIF(LOWER(transaction_type), 'not recorded') AS transaction_type,
        postcode,
        posttown,
        local_authority,
        uprn,
        property_type,
        NULLIF(LOWER(tenure), 'unknown') AS tenure
    FROM
        cleaned
),


typed AS(
  SELECT
    certificate_number,
    SAFE.PARSE_DATE('%F', inspection_date) AS inspection_date,
    SAFE.PARSE_DATE('%F', lodgement_date) AS lodgement_date,
    SAFE_CAST(total_floor_area AS INT64) AS total_floor_area,
    SAFE_CAST(floor_height AS FLOAT64) AS floor_height,
    current_energy_rating,
    SAFE_CAST(current_energy_efficiency AS INT64) AS current_energy_efficiency,
    SAFE_CAST(energy_consumption_current AS FLOAT64) AS energy_consumption_current,
    SAFE_CAST(heating_cost_current AS FLOAT64) AS heating_cost_current,
    SAFE_CAST(potential_energy_efficiency AS INT64) AS potential_energy_efficiency,
    SAFE_CAST(number_habitable_rooms AS INT64) AS number_habitable_rooms,
    SAFE_CAST(number_heated_rooms AS INT64) AS number_heated_rooms,
    SAFE_CAST(extension_count AS INT64) AS extension_count,
    built_form,
    construction_age_band,
    transaction_type,
    postcode,
    posttown,
    local_authority,
    uprn,
    property_type,
    tenure
  FROM
    standardised
),

validated AS(
    SELECT
        certificate_number,
        inspection_date,
        lodgement_date,
        NULLIF(total_floor_area, 0) AS total_floor_area,
        CASE WHEN floor_height < 1.5 THEN NULL ELSE floor_height END AS floor_height,
        current_energy_rating,
        current_energy_efficiency,
        energy_consumption_current,
        heating_cost_current,
        potential_energy_efficiency,
        number_habitable_rooms,
        number_heated_rooms,
        extension_count,
        built_form,
        construction_age_band,
        CASE 
            WHEN REGEXP_CONTAINS(construction_age_band, r'^\d{4}$') 
                AND (SAFE_CAST(construction_age_band AS INT64) BETWEEN 1500 AND 2025) 
                THEN SAFE_CAST(construction_age_band AS INT64)
            ELSE NULL 
            END AS build_year,
        transaction_type,
        postcode,
        posttown,
        local_authority,
        uprn,
        property_type,
        tenure,
        inspection_date < DATE '2007-08-01' AS is_suspect_inspection_date,
        COALESCE(floor_height > 20, FALSE) AS is_suspect_floor_height
    FROM
        typed

),

age_banded AS(
    SELECT
        certificate_number,
        inspection_date,
        lodgement_date,
        total_floor_area,
        floor_height,
        current_energy_rating,
        current_energy_efficiency,
        energy_consumption_current,
        heating_cost_current,
        potential_energy_efficiency,
        number_habitable_rooms,
        number_heated_rooms,
        extension_count,
        built_form,
        construction_age_band AS construction_age_band_raw,
        CASE
            WHEN c.age_band IS NOT NULL THEN c.age_band 
            WHEN build_year < 1900 THEN 'before 1900'
            WHEN build_year < 1930 THEN '1900-1929'
            WHEN build_year < 1950 THEN '1930-1949'
            WHEN build_year < 1967 THEN '1950-1966'
            WHEN build_year < 1976 THEN '1967-1975'
            WHEN build_year < 1983 THEN '1976-1982'
            WHEN build_year < 1991 THEN '1983-1990'
            WHEN build_year < 1996 THEN '1991-1995'
            WHEN build_year < 2003 THEN '1996-2002'
            WHEN build_year < 2007 THEN '2003-2006'
            WHEN build_year <= 2025 THEN '2007 onwards'
            ELSE NULL
            END AS construction_age_band,
        build_year,
        transaction_type,
        postcode,
        posttown,
        local_authority,
        uprn,
        property_type,
        tenure,
        is_suspect_inspection_date,
        is_suspect_floor_height
    FROM
        validated v
    LEFT JOIN `reference.construction_age_band_map` c ON v.construction_age_band = c.raw_value

),
ref_bands AS(
    SELECT DISTINCT
        age_band,
        sort_order
    FROM
        `reference.construction_age_band_map`
)

SELECT
    certificate_number,
    inspection_date,
    lodgement_date,
    total_floor_area,
    floor_height,
    current_energy_rating,
    current_energy_efficiency,
    energy_consumption_current,
    heating_cost_current,
    potential_energy_efficiency,
    number_habitable_rooms,
    number_heated_rooms,
    extension_count,
    built_form,
    construction_age_band_raw,
    construction_age_band,
    r.sort_order AS construction_age_band_sort_order,
    build_year,
    transaction_type,
    postcode,
    posttown,
    local_authority,
    uprn,
    property_type,
    tenure,
    is_suspect_inspection_date,
    is_suspect_floor_height
FROM
  age_banded a
LEFT JOIN ref_bands r ON a.construction_age_band = r.age_band;

