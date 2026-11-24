# oxfordshire-house-prices-warehouse
BigQuery warehouse for Oxfordshire house sales: HM Land Registry Price Paid
data linked to EPC certificates and modelled in SQL for Power BI.

**Status:** (23 Nov 2026) Raw price paid, EPC and match table loaded to BigQuery. Rows counts match the pipeline. Next steps: profiling, then SQL rebuild of the pipeline's downstream steps.

## Why this exists
My pandas pipeline does the rule-based address matching of Land Registry sales with EPC certificates. This repo rebuilds all the subsequent cleaning and filtering in SQL/BigQuery, ending in a star schema for Power BI to read.

## Architecture
<!-- The flow: raw PP + raw EPC + match table → BigQuery
→ staging → intermediate → marts → Power BI.
A simple text diagram is fine for now. -->

## Data sources
Neither dataset is included in the repo. To reproduce the results:

**Price Paid Data.** Use the [report builder](https://landregistry.data.gov.uk/app/ppd) and run one search per district: Cherwell, Oxford, South Oxfordshire, Vale of White Horse and West Oxfordshire. Set the dates to 1 Jan 2015 to 31 Dec 2025, choose "all" results, and download as CSV with headers. Save the five files in `data/raw/` with names starting `ppd_data` (unchanged from downloads). Field definitions are on the [Land Registry guidance page](https://www.gov.uk/guidance/about-the-price-paid-data).

**Energy Performance Certificates.** Download from [Get energy performance of buildings data](https://get-energy-performance-data.communities.gov.uk/) (you need a GOV.UK One Login account). Select domestic certificates lodged between Sept 2008 (the start of the register) and Dec 2025 for the same five local authorities. Certificates are valid for 10 years, so sales from 2015 onwards can depend on certificates lodged well before 2015. Save the CSV in `data/raw/` as `EDC_OXFORDSHIRE_2008_2025.csv`. A data dictionary with definitions for the columns can be found at [Link to Domestic EPC Data Dictionary](https://get-energy-performance-data.communities.gov.uk/guidance/data-dictionary).

Contains HM Land Registry data © Crown copyright and database right 2021. This data is licensed under the Open Government Licence v3.0.

## Repository layout

```text
oxfordshire-house-prices-warehouse/
├── README.md
├── .gitignore
├── docs/
│   ├── decisions.md        
│   ├── setup_notes.md      
│   └── reconciliation.md 
├── load/
├── seeds/                   
├── sql/
│   ├── profiling/          
│   ├── staging/            
│   ├── intermediate/       
│   └── marts/             
├── powerbi/                
└── data/                   
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