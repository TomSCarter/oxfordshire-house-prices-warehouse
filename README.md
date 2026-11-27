# oxfordshire-house-prices-warehouse
BigQuery warehouse for Oxfordshire house sales: HM Land Registry Price Paid data linked to EPC certificates and modelled in SQL for Power BI.

**Status (27 Nov 2026):** Raw, staging, intermediate and marts layers built and reconciled against the pandas pipeline. Next: connecting Power BI to the star schema.

## Why this exists
My pandas pipeline does the rule-based address matching of Land Registry sales with EPC certificates. This repo rebuilds all the subsequent cleaning and filtering in SQL/BigQuery, ending in a star schema for Power BI to read.

## Architecture

```text
Price Paid CSVs ─┐
EPC CSV ─────────┼─→ Cloud Storage ─→ raw ─→ staging ─→ intermediate ─→ marts ─→ Power BI
Match table ─────┘   (EPC > 100 MB)    │                                  │
(from the pandas                        └── reference (lookup tables) ─────┘
 pipeline)
```

Address matching stays in Python. The pipeline exports the (sale, certificate) pairs as the match table, and everything downstream is SQL.

## Data sources
Neither dataset is included in the repo. To reproduce the results:

**Price Paid Data.** Use the [report builder](https://landregistry.data.gov.uk/app/ppd) and run one search per district: Cherwell, Oxford, South Oxfordshire, Vale of White Horse and West Oxfordshire. Set the dates to 1 Jan 2015 to 31 Dec 2025, choose "all" results, and download as CSV with headers. Save the five files in `data/raw/` with names starting `ppd_data` (unchanged from downloads). Field definitions are on the [Land Registry guidance page](https://www.gov.uk/guidance/about-the-price-paid-data).

**Energy Performance Certificates.** Download from [Get energy performance of buildings data](https://get-energy-performance-data.communities.gov.uk/) (you need a GOV.UK One Login account). Select domestic certificates lodged between Sept 2008 (the start of the register) and Dec 2025 for the same five local authorities. Certificates are valid for 10 years, so sales from 2015 onwards can depend on certificates lodged well before 2015. Save the CSV in `data/raw/` as `EDC_OXFORDSHIRE_2008_2025.csv`. A data dictionary is available: [Domestic EPC Data Dictionary](https://get-energy-performance-data.communities.gov.uk/guidance/data-dictionary).

**Match table.** Produced by the [cleaning pipeline](https://github.com/TomSCarter/land-registry-cleaning-pipeline): one row per (sale, certificate) pair after address matching, before any downstream filtering.

Contains HM Land Registry data © Crown copyright and database right 2021. This data is licensed under the Open Government Licence v3.0.

Energy Performance of Buildings Data: England and Wales, Ministry of Housing, Communities and Local Government. Contains public sector information licensed under the Open Government Licence v3.0.

## Repository layout

```text
oxfordshire-house-prices-warehouse/
├── README.md
├── .gitignore
├── docs/
│   ├── decisions.md        # design decisions and why
│   ├── setup_notes.md      # BigQuery and Power BI setup problems and fixes
│   ├── staging_rules.md    # cleaning rules found by profiling
│   └── reconciliation.md   # SQL counts against the pandas pipeline
├── load/                   # schema generator script and all-STRING schemas for raw loads
├── seeds/                  # hand-written lookup tables (future dbt seeds)
├── sql/
│   ├── profiling/          # checks on raw data before modelling
│   ├── staging/            # one view per source: clean values, convert types
│   ├── intermediate/       # pipeline filters: ambiguity, pre-sale certificate, exclusions
│   ├── marts/              # star schema tables for Power BI
│   └── checks/             # checks per model (row counts, uniqueness, joins)
├── logs/                   # daily notes
├── powerbi/                # notes and measures (.pbix ignored)
└── data/                   # ignored: local raw and processed files
```

## Warehouse layers
All datasets are in europe-west2 (London).

| Dataset | Holds | Built as |
|---|---|---|
| `raw` | Source data exactly as received, every column as STRING: `price_paid`, `epc`, `match_table` | Tables (loaded) |
| `reference` | Hand-written lookups: `construction_age_band_map` | Table (from `seeds/`) |
| `staging` | One model per source: trimmed, empty strings → NULL, types converted, categories standardised, quality flags. No rows removed; address fields dropped | Views |
| `intermediate` | The pipeline's downstream logic, one step per model: `int_match_pairs` → `int_matches_unambiguous` → `int_sales_presale_epc` → `int_sales_filtered` | Views |
| `marts` | Star schema: `fact_sales` (one row per sale, all 135,557), `dim_certificate` (certificates linked to a sale, plus UNKNOWN), `dim_date` (2015–2025) | Tables |

## Reconciliation
Row counts match the pandas pipeline exactly at every step:
171,240 pairs → 164,823 (118,222 sales) → 114,490 → 114,424.
Column-level null counts match to within ±1, explained by 333 sales with tied
certificates, plus one deliberate fix (174 'Unknown' tenures the pipeline missed).
Full tables and differences: [reconciliation.md](docs/reconciliation.md)

## Design decisions
Full reasoning in [decisions.md](docs/decisions.md).
1. BigQuery rather than DuckDB, for cloud warehouse experience
2. Power BI connects with a read-only service account
3. Fact grain: one row per sale, including sales without a certificate (linked to an UNKNOWN certificate row)
4. No property dimension for now; `dim_certificate` keyed on certificate number
5. Data minimisation: address fields finer than postcode stay in `raw` only
6. `dim_certificate` holds only certificates linked to a sale
7. Ties in certificate selection go to the larger floor area (the main dwelling rather than an annexe), then the certificate number

## Reproducing it
1. Download the source data (above) and run the cleaning pipeline to produce the match table.
2. Set up a GCP project with billing and a budget alert (see [setup_notes.md](docs/setup_notes.md)).
3. Create a Cloud Storage bucket in europe-west2 and upload the Price Paid and EPC CSVs.
4. Generate the all-STRING schemas: `python load/make_schema.py <csv> <output.json>`.
5. Create the `raw` tables from the bucket (Price Paid via the `ppd_data*.csv` wildcard) and upload the match table Parquet.
6. Upload `seeds/construction_age_band_map.csv` to `reference.construction_age_band_map`.
7. Run the SQL in order: `sql/staging/` → `sql/intermediate/` → `sql/marts/`, then the queries in `sql/checks/`.
8. Connect Power BI Desktop with the service account (see setup notes).

## Data privacy
No address-level data is committed to this repo. Raw and processed data, .pbix files and credentials are gitignored. Address fields are dropped after the raw layer, and published outputs are aggregated only.

## How this was built
I used Claude as a tutor and reviewer: explaining concepts, reviewing my SQL, and helping draft documentation. The SQL, the data modelling and the design decisions are my own.

## Related repos
- [land-registry-cleaning-pipeline](https://github.com/TomSCarter/land-registry-cleaning-pipeline): cleaning and address matching (pandas)
- [oxfordshire-house-prices-dashboard](https://github.com/TomSCarter/oxfordshire-house-prices-dashboard): public Streamlit dashboard