# oxfordshire-house-prices-warehouse
BigQuery warehouse for Oxfordshire house sales: HM Land Registry Price Paid
data linked to EPC certificates and modelled in SQL for Power BI.

**Status:** (19 Nov 2026) BigQuery set up and connection to Power BI tested. Match table exported from the Land registry pipeline. Next: raw loads and SQL rebuild of the pipeline's downstream steps.

## Why this exists
My pandas pipeline does the rule-based address matching of Land Registry sales with EPC certificates. This repo rebuilds all the subsequent cleaning and filtering in SQL/BigQuery, ending in a star schema for Power BI to read.

## Architecture
<!-- The flow: raw PP + raw EPC + match table → BigQuery
→ staging → intermediate → marts → Power BI.
A simple text diagram is fine for now. -->

## Data sources
<!-- Price Paid (HM Land Registry), EPC (DLUHC/MHCLG): links, licences,
date range, Oxfordshire local authorities. -->

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

## Reproducing it
<!-- Prerequisites (GCP project, billing, budget alert), how to load the raw data,
how to run the SQL, how to connect Power BI. Link to docs/setup_notes.md. -->

## Data privacy
No address-level data is committed to this repo. Raw and processed data,
.pbix files and credentials are gitignored; published outputs are aggregated only.

## Related repos
- [land-registry-cleaning-pipeline](https://github.com/TomSCarter/land-registry-cleaning-pipeline): cleaning and address matching (pandas)
- [oxfordshire-house-prices-dashboard](https://github.com/TomSCarter/oxfordshire-house-prices-dashboard): public Streamlit dashboard