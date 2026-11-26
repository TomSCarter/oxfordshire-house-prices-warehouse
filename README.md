# oxfordshire-house-prices-warehouse
BigQuery warehouse for Oxfordshire house sales: HM Land Registry Price Paid data linked to EPC certificates and modelled in SQL for Power BI.

**Status (26 Nov 2026):** Raw, staging and intermediate layers built; the SQL reproduces the pandas pipeline's row counts at every step. Marts in progress: `dim_certificate` and `dim_date` done, `fact_sales` next, then Power BI.

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

Address matching stays in Python. The pipeline exports the (sale, certificate)
pairs as the match table, and everything downstream is SQL.

## Data sources
Neither dataset is included in the repo. To reproduce the results:

**Price Paid Data.** Use the [report builder](https://landregistry.data.gov.uk/app/ppd) and run one search per district: Cherwell, Oxford, South Oxfordshire, Vale of White Horse and West Oxfordshire. Set the dates to 1 Jan 2015 to 31 Dec 2025, choose "all" results, and download as CSV with headers. Save the five files in `data/raw/` with names starting `ppd_data` (unchanged from downloads). Field definitions are on the [Land Registry guidance page](https://www.gov.uk/guidance/about-the-price-paid-data).

**Energy Performance Certificates.** Download from [Get energy performance of buildings data](https://get-energy-performance-data.communities.gov.uk/) (you need a GOV.UK One Login account). Select domestic certificates lodged between Sept 2008 (the start of the register) and Dec 2025 for the same five local authorities. Certificates are valid for 10 years, so sales from 2015 onwards can depend on certificates lodged well before 2015. Save the CSV in `data/raw/` as `EDC_OXFORDSHIRE_2008_2025.csv`. A data dictionary with definitions for the columns can be found at [Link to Domestic EPC Data Dictionary](https://get-energy-performance-data.communities.gov.uk/guidance/data-dictionary).

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
│   └── checks/             # checks per model (e.g. row counts, uniqueness etc) 
├── logs/                   # daily notes
├── powerbi/                # notes and measures (.pbix ignored)
└── data/                   # ignored: local raw and processed files
```

## Warehouse layers
<!-- raw / staging / intermediate / marts: what each holds, and which
BigQuery dataset it lives in. -->

## Reconciliation
[Table of pipeline numbers to check against](docs/reconciliation.md)

## Design decisions
<!-- One line per decision, linking to docs/decisions.md. -->
[Decisions log](docs/decisions.md)

## Reproducing it
<!-- Prerequisites (GCP project, billing, budget alert), how to load the raw data,
how to run the SQL, how to connect Power BI. Link to docs/setup_notes.md. -->

## Data privacy
No address-level data is committed to this repo. Raw and processed data,
.pbix files and credentials are gitignored; published outputs are aggregated only.

## Related repos
- [land-registry-cleaning-pipeline](https://github.com/TomSCarter/land-registry-cleaning-pipeline): cleaning and address matching (pandas)
- [oxfordshire-house-prices-dashboard](https://github.com/TomSCarter/oxfordshire-house-prices-dashboard): public Streamlit dashboard