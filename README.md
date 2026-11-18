# oxfordshire-house-prices-warehouse
BigQuery warehouse for Oxfordshire house sales: HM Land Registry Price Paid data linked to EPC certificates and modelled in SQL for Power BI

## Setting up BigQuery-PowerBi connection
- After setting up my BigQuery account the organisation policy blocked key creation (for the powerbi service account). Had to give myself rights to change the policy
- When setting up the connection in PowerBi desktop, the json key had to be formatted into one line, otherwise errored
- When creating the service account I gave it the roles: Data viewer, Job user and Read session user
