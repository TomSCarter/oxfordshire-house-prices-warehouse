# Decisions

- Chose to use BigQuery rather than DuckDB
    - I want cloud experience for my CV
    - Employers mostly run cloud warehouses, and my benchmark ads named BigQuery (or Snowflake) not DuckDB. Chose BigQuery over Snowflake as free tier and charging model work better for training, it was also mentioned in several of the ads. I gather its not too hard to transfer skills between providers
    - I enabled billing but set a £5 alert, to get full access to the features

- Power BI signs in with a service account key
    - Its the professional way to do it, but the default organisation policy on BigQuery blocked the generation of a key. I had to give myself privileges to override it at a project level.
    - On the service account, I gave Power BI three roles (minimum needed, all read-only)
    - The cost is the security risk on the key as a long-lived secret that could give unintentional access
    - Alternative: I could have just allowed Power BI to sign in with my Google account, but that would have allowed it project owner level access

- The fact table's grain
    - one row per sale of a property (all sales)
    - Measure: price paid
    - Dimensions: date, district/location, property type, certificate
    - EPC attributes (floor_area, rating etc) will be in dim_certificate.
    - £/m2 will be calculated in Power BI and blank for any unmatched sales.
    - Sales without a certificate are kept as still useful in analyses that doesnt need the EPC data
        - match them to an unknown certificate row, so they can be filtered out of analyses that do need certificate info
- Property key
    - No unique key for each property, but there is for each sale (unique_id)
        - It would be nice to be able to look at multiple sales/certificates for a single property, but there is not a clear way to link them (more address matching).
            - HM Land Registry's sale-to-UPRN lookup (from August 2026) covers only new Price Paid records, with no back-dated data, so it can't provide a property key for 2015–2025 sales. It would only help if the project is extended to sales from late 2026 onwards
        - But none of my current analysis needs this, no property key for now
    - EPC all have unique certificate numbers with UPRN for each property (but some few uprn are null)
        - dim_certificate to be keyed on certificate_number, holding the properties attributes as of each sale

- House number/name, flat, street and locality are left out of staging. Postcode, town, district and county are kept for geography.
    - Address data is under Royal Mail/OS terms (non-commercial use only) and isn't needed after matching, so it stays in raw only.

- Only certificates linked to a sale to be kept in dim_certificate (marts)
    - Smaller and every row is used in a sale, Power BI's lists and slicers don't get filled with certificates never in the facts
    - Avoids dealing with the 5 non-oxfordshire records that had to be filtered out in the pipeline
    - Will add an UNKNOWN row for all unlinked sales to point to
    - Could add the full set at a later date, if we wanted to analyse the whole housing stock (e.g. spread of ratings etc)

- Add floor area as a tie break on EPC selection (after inspection and lodgement dates). The python pipeline had no tie-break, so ties were settled arbitrarily by sort order
    - There is a sale with unique_id (49E87C32-4DD3-591C-E063-4704A8C00C31) matches to two EPCs inspected and lodged on identical days, the sale price is above £1.5 million and one EPC has 52 sqm floor area and the other 243 sqm. It seems likely one EPC is for an annex.
    - Tie-break for larger floor_area will typically select the main house, which better reflects the sale price.
    - NULL floor areas sorted last