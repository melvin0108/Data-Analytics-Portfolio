# ICMRA Strategic Analytics Platform

**Modern Data Stack:** Snowflake + dbt + Power BI

> A production-grade data transformation and business intelligence solution for the International Consortium for Medical Research Advancement (ICMRA). This project migrates fundraising analytics (2019-2025) from a Power BI-only architecture to a layered data warehouse approach with dbt-managed transformations and Snowflake as the analytical engine.

---

## Architecture

```
                          ┌──────────────────────────────────────────────┐
                          │            PRESENTATION LAYER                │
                          │                                              │
                          │   Power BI Desktop / Power BI Service        │
                          │   ├─ 10 report pages, 69 visuals            │
                          │   ├─ 25 DAX measures (interactive only)      │
                          │   └─ Import mode from ANALYTICS schema       │
                          └──────────────────┬───────────────────────────┘
                                             │ Snowflake connector
                                             ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│                          TRANSFORMATION LAYER (dbt)                             │
│                                                                                 │
│   ┌──────────┐     ┌────────────────┐     ┌──────────────────────────────┐     │
│   │ Staging  │────►│ Intermediate   │────►│ Marts (Star Schema)          │     │
│   │          │     │                │     │                              │     │
│   │ stg_*    │     │ int_*          │     │ dim_date                     │     │
│   │ 4 models │     │ 2 models       │     │ dim_account                  │     │
│   │          │     │                │     │ dim_campaign                 │     │
│   │ Type cast│     │ Calc columns   │     │ dim_contribution             │     │
│   │ Rename   │     │ Business logic │     │ fct_pledges                  │     │
│   │ Null trim│     │ Enrichment     │     │                              │     │
│   │          │     │                │     │ + Analytics marts:            │     │
│   │          │     │                │     │   rfm_analysis               │     │
│   │          │     │                │     │   cohort_retention           │     │
│   │          │     │                │     │   basket_pairs               │     │
│   │          │     │                │     │   clv_analysis               │     │
│   └──────────┘     └────────────────┘     └──────────────────────────────┘     │
│                                                                                 │
│   dbt Cloud / dbt CLI ── CI/CD via GitHub Actions                              │
└────────────────────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│                          STORAGE LAYER (Snowflake)                              │
│                                                                                 │
│   Database: ICMRA_DB                                                            │
│   ├── RAW schema        ── Source data landing zone                             │
│   ├── STAGING schema    ── Cleaned & typed tables (dbt managed)                 │
│   ├── ANALYTICS schema  ── Star schema marts (dbt managed)                      │
│   └── REPORTING schema  ── Pre-aggregated executive tables                      │
│                                                                                 │
│   Warehouse: ICMRA_WH (X-Small, auto-suspend 60s)                               │
│   Time Travel: 30 days on analytics, 7 days on raw                              │
└────────────────────────────────────────────────────────────────────────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │  Excel Source │  ICMRA Dataset 2019-2025.xlsx
                   │  (4 tables)   │  Loaded via Snowflake COPY INTO
                   └──────────────┘
```

---

## Project Structure

```
Testing/
├── Report.pbix                              # Power BI dashboard (consumes ANALYTICS schema)
├── README.md                                # This file
├── Makefile                                 # Quick-start commands
├── .gitignore                               # Git exclusions
│
├── snowflake/                               # Snowflake infrastructure-as-code
│   ├── 01_create_database.sql               # Database, schemas, RBAC roles
│   ├── 02_create_raw_tables.sql             # Raw landing tables (source-of-truth)
│   ├── 03_load_data.sql                     # COPY INTO from staged Excel
│   ├── 04_create_warehouse.sql              # Virtual warehouse sizing
│   └── snowflake_config.yml                 # Connection reference card
│
├── dbt_project/                             # dbt transformation project
│   ├── dbt_project.yml                      # Project configuration
│   ├── profiles.yml                         # Snowflake connection profile
│   ├── packages.yml                         # dbt packages (dbt_utils, dbt_expectations)
│   ├── .env.example                         # Environment variables template
│   │
│   ├── models/
│   │   ├── staging/                         # Layer 1: Source-to-staging
│   │   │   ├── sources.yml                  # Source table registrations
│   │   │   ├── stg_pledges.sql
│   │   │   ├── stg_campaigns.sql
│   │   │   ├── stg_accounts.sql
│   │   │   └── stg_contributions.sql
│   │   │
│   │   ├── intermediate/                    # Layer 2: Business logic enrichment
│   │   │   ├── int_pledges_enriched.sql     # Calculated columns (payment status, cohort)
│   │   │   └── int_account_activity.sql     # Account-level aggregations
│   │   │
│   │   ├── marts/                           # Layer 3: Star schema + analytics
│   │   │   ├── schema.yml                   # Tests, docs, relationships
│   │   │   ├── dim_date.sql                 # Date dimension (2019-2025)
│   │   │   ├── dim_account.sql              # Account dimension (+ churn flag)
│   │   │   ├── dim_campaign.sql             # Campaign dimension
│   │   │   ├── dim_contribution.sql         # Contribution type dimension
│   │   │   ├── fct_pledges.sql              # Central fact table
│   │   │   ├── rfm_analysis.sql             # RFM segmentation mart
│   │   │   ├── cohort_retention.sql         # Cohort retention matrix
│   │   │   ├── basket_pairs.sql             # Market basket association rules
│   │   │   └── clv_analysis.sql             # Customer lifetime value mart
│   │   │
│   │   └── reporting/                       # Layer 4: Executive aggregations
│   │       └── exec_summary.sql             # Board-level KPI summary
│   │
│   ├── macros/                              # Reusable SQL fragments
│   │   ├── date_spine.sql                   # Generate date dimension rows
│   │   └── generate_surrogate_key.sql       # Hash-based surrogate keys
│   │
│   ├── seeds/                               # Static reference data (CSV)
│   │   └── rfm_segment_mapping.csv          # RFM score-to-segment lookup
│   │
│   ├── tests/                               # Custom data quality tests
│   │   ├── assert_no_negative_amounts.sql
│   │   ├── assert_payment_date_after_close.sql
│   │   └── assert_unique_pledge_id.sql
│   │
│   ├── analyses/                            # Ad-hoc analytical queries
│   │   ├── annual_kpi_summary.sql
│   │   └── donor_cohort_analysis.sql
│   │
│   └── snapshots/                           # SCD Type 2 change tracking
│       └── snap_pledges.sql
│
└── .github/
    └── workflows/
        └── dbt_ci_cd.yml                    # CI/CD pipeline (lint, test, deploy)
```

---

## Data Lineage (dbt DAG)

```
sources                     staging                  intermediate              marts
────────                    ───────                  ─────────────             ─────

RAW.medical_research  ──►  stg_pledges      ──►
grant_appeal                                    int_pledges_enriched  ──►  fct_pledges
                                                │                       ──►  cohort_retention
                                                │
RAW.account           ──►  stg_accounts     ──►  int_account_activity  ──►  dim_account
                                                                         ──►  rfm_analysis
                                                                         ──►  clv_analysis

RAW.mra_campaign      ──►  stg_campaigns    ───────────────────────────►  dim_campaign

RAW.contribution      ──►  stg_contributions───────────────────────────►  dim_contribution

(date_spine macro)    ─────────────────────────────────────────────────►  dim_date

(fct_pledges + dim_contribution)              ─────────────────────────►  basket_pairs

(all marts)                                    ─────────────────────────►  exec_summary
```

---

## Quick Start

### Prerequisites

- [Snowflake account](https://signup.snowflake.com/) (trial works)
- [dbt Core](https://docs.getdbt.com/dbt-cli/installation) >= 1.7 or [dbt Cloud](https://www.getdbt.com/product/dbt-cloud)
- [Power BI Desktop](https://powerbi.microsoft.com/desktop/) >= 2.153
- Python >= 3.10, Git

### 1. Snowflake Setup

```bash
# Run Snowflake infrastructure scripts in order
make snowflake-setup
# Or manually via SnowSQL:
# snowsql -f snowflake/01_create_database.sql
# snowsql -f snowflake/02_create_raw_tables.sql
# snowsql -f snowflake/03_load_data.sql
# snowsql -f snowflake/04_create_warehouse.sql
```

### 2. Configure dbt

```bash
cd dbt_project

# Copy environment template and fill in your credentials
cp .env.example .env

# Verify connection
dbt debug

# Install dbt packages
dbt deps
```

### 3. Build the Warehouse

```bash
# Full build: staging → intermediate → marts → reporting
dbt build

# Or run layer by layer:
dbt run --select staging
dbt run --select intermediate
dbt run --select marts
dbt run --select reporting

# Run tests
dbt test

# Generate documentation
dbt docs generate && dbt docs serve
```

### 4. Connect Power BI

1. Open `Report.pbix` in Power BI Desktop
2. **Get Data** > **Snowflake**
3. Server: `your-account.snowflakecomputing.com`
4. Database: `ICMRA_DB`, Schema: `ANALYTICS`
5. Import all `dim_*` and `fct_*` tables
6. Set relationships in Model view (4 relationships, single-direction)
7. Add the 25 remaining DAX measures to `_Measures`

---

## dbt Model Summary

| Model | Layer | Materialization | Description |
|---|---|---|---|
| `stg_pledges` | Staging | Table | Typed & renamed pledge transactions |
| `stg_campaigns` | Staging | Table | Campaign master data |
| `stg_accounts` | Staging | Table | Account/contributor master data |
| `stg_contributions` | Staging | Table | Contribution type lookup |
| `int_pledges_enriched` | Intermediate | Table | Fact table with calculated columns (payment status, cohort keys, days to pay) |
| `int_account_activity` | Intermediate | Table | Per-account aggregated activity metrics |
| `dim_date` | Mart | Table | Date dimension 2019-01-01 to 2025-12-31 |
| `dim_account` | Mart | Table | Account dimension with pre-computed churn flag |
| `dim_campaign` | Mart | Table | Campaign dimension with calculated fields |
| `dim_contribution` | Mart | Table | Contribution type dimension |
| `fct_pledges` | Mart | Incremental | Central fact table (enriched pledges) |
| `rfm_analysis` | Mart | Table | Per-account RFM scores, quintiles, segment labels |
| `cohort_retention` | Mart | Table | Pre-aggregated cohort retention matrix |
| `basket_pairs` | Mart | Table | Market basket co-occurrence with support/confidence/lift |
| `clv_analysis` | Mart | Table | Customer lifetime value per account |
| `exec_summary` | Reporting | Table | Board-level KPI aggregates |

---

## Power BI: What Changed

| Before (Power BI only) | After (Snowflake + dbt + PBI) |
|---|---|
| 19 tables in model view | 9 tables in model view |
| 8 relationships (incl. 3 inactive, 2 bidirectional) | 4 relationships (all active, single-direction) |
| 114 DAX measures | 25 DAX measures |
| 6 calculated columns in fact table | 0 calculated columns |
| 5 calculated tables (Dim_Date, RFM, Dim_RankRFM, BasketPairs) | 0 calculated tables |
| Power Query does all ETL | dbt does all ETL |
| Single-user .pbix file | Team-collaborative git repo |

### 25 Remaining DAX Measures

| Category | Measures | Why They Stay |
|---|---|---|
| What-If Parameters | `Growth Rate Selected`, `Goal Target Selected`, `Projected Paid`, `Gap to Goal`, `Goal Status Color`, `Selected Measure Value` | React to slider/toggle interaction |
| Conditional Formatting | `* Trend Color`, `Line Bar Color`, `Sparkline Marker Color`, `* Color` | Drive visual formatting at runtime |
| KPI Display Strings | `* Growth KPI` (7 measures) | Formatted "▲/▼" strings |
| Sparkline Highlights | `Max *`, `Min *` (12 measures) | Runtime max/min detection |
| Dynamic Titles | 5 title measures | `SELECTEDVALUE` slicer-driven |

---

## Power BI — Post-Snowflake Model View

After connecting Power BI to the `ANALYTICS` schema in Snowflake, the Model View changes from a complex spider web to a clean star schema.

### Before: Current Power BI Model (19 tables)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                           Dim_Date (calculated)                                │
│                          ╱    │         ╲                                       │
│               (active) ╱     │(inactive) ╲(inactive)                            │
│                      ╱       │             ╲                                    │
│   ┌──────────────────────────────────────┐    ┌──────────────────────┐          │
│   │ Medical Research Grant Appeal (fact)  │    │   MRA Campaign       │          │
│   │                                       │───►│   (dimension)        │          │
│   │  8 source columns                     │    │   11 source columns  │          │
│   │  + 6 DAX calculated columns:          │    └──────────────────────┘          │
│   │    • Payment Status                   │                                      │
│   │    • First Payment Date               │         ┌──────────────────────┐    │
│   │    • First Payment Month              │─────────►│  Contribution        │    │
│   │    • Payment Month                    │          │  (dimension)         │    │
│   │    • Month Offset                     │          │  3 source columns    │    │
│   │    • Days to Pay                      │          └──────────────────────┘    │
│   └────────┬──────────────────────────────┘                                      │
│            │                                                                     │
│            │       ┌──────────────────┐       ┌──────────────────┐               │
│            ├──────►│    Account        │◄─────►│    RFM            │               │
│            │       │  (dimension)      │ BIDI  │  (calculated)     │◄──┐          │
│            │       │  11 source cols   │       │  R/F/M + quintile │   │          │
│            │       │  + Churn Flag     │       │  scores per acct  │   │ BIDI     │
│            │       └──────────────────┘       └──────────────────┘   │          │
│            │                                                         │          │
│            │                                   ┌──────────────────┐   │          │
│            │                                   │  Dim_RankRFM     │◄──┘          │
│            │                                   │  (calculated)    │              │
│            │                                   │  125 rows,       │              │
│            │                                   │  11 segments     │              │
│            │                                   └──────────────────┘              │
│            │                                                                     │
│            │       BasketPairs (calculated, orphaned — no FK to fact)            │
│            │       Cohort logic (embedded as DAX measures on fact)               │
│            │       _Measures (placeholder — 114 measures)                        │
│            │       4× Parameter tables (Growth Rate, Goal Target, Top N, Select) │
│            │       5× LocalDateTable_* (hidden, auto-generated clutter)          │
│            │                                                                     │
│            │   Relationships: 8 total                                            │
│            │     5 active (single-direction)                                     │
│            │     3 inactive (USERELATIONSHIP)                                    │
│            │     2 bidirectional (RFM ↔ Account, RFM ↔ Dim_RankRFM)             │
│            │                                                                     │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### After: Snowflake + dbt Model (9 tables)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                          ┌──────────────────┐                                   │
│                          │    dim_date       │                                   │
│                          │                  │                                   │
│                          │  date       (PK) │                                   │
│                          │  year            │                                   │
│                          │  quarter         │                                   │
│                          │  month_num       │                                   │
│                          │  month_name      │                                   │
│                          │  year_month      │                                   │
│                          │  fiscal_year     │                                   │
│                          │  is_weekend      │                                   │
│                          │  ...             │                                   │
│                          └────────┬─────────┘                                   │
│                                   │ (active, 1:*)                               │
│                                   ▼                                             │
│   ┌──────────────────┐   ┌──────────────────────────────┐   ┌────────────────┐  │
│   │  dim_campaign     │   │      fct_pledges (fact)       │   │  dim_account   │  │
│   │                  │   │                              │   │                │  │
│   │  campaign_code   │◄──│  pledge_id              (PK) │──►│  account_code  │  │
│   │  campaign_name   │   │  account_id            (FK) │   │  account_name  │  │
│   │  research_area   │   │  campaign_id           (FK) │   │  account_type  │  │
│   │  campaign_type   │   │  cont_type_id          (FK) │   │  country       │  │
│   │  priority_level  │   │  payment_date_key      (FK) │   │  region        │  │
│   │  target_amount   │   │  referral_source            │   │  segment       │  │
│   │  campaign_budget │   │  pledge_pay_amount          │   │  churn_flag    │  │
│   │  target_achieve% │   │  payment_status             │   │  account_status│  │
│   │  roi             │   │  first_payment_month        │   │  last_pay_date │  │
│   │  pledge_conv%    │   │  payment_month              │   │  tenure_months │  │
│   │  channel_focus   │   │  month_offset               │   │  ...           │  │
│   └──────────────────┘   │  days_to_pay                │   └────────────────┘  │
│                          │  appeal_close_date          │                       │
│                          └──────────────┬───────────────┘                       │
│                                         │ (active, 1:*)                         │
│                                         ▼                                        │
│                          ┌──────────────────┐                                    │
│                          │ dim_contribution  │                                    │
│                          │                  │                                    │
│                          │  contribution_id │                                    │
│                          │  contribution_   │                                    │
│                          │   type / group   │                                    │
│                          └──────────────────┘                                    │
│                                                                                  │
│   ── Relationships: 4 total, ALL active, ALL single-direction (1:*) ──          │
│                                                                                  │
│   fct_pledges.payment_date_key  ──►  dim_date.date                              │
│   fct_pledges.account_id        ──►  dim_account.account_code                   │
│   fct_pledges.campaign_id       ──►  dim_campaign.campaign_code                 │
│   fct_pledges.cont_type_id      ──►  dim_contribution.contribution_id           │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│  Standalone Analytics Marts (no relationships — feed visuals directly)           │
│                                                                                  │
│  ┌─────────────────────────────────┐                                             │
│  │  rfm_analysis                   │   ┌─────────────────────────────────┐       │
│  │                                │   │  cohort_retention                │       │
│  │  account_id               (PK) │   │                                 │       │
│  │  recency_days                  │   │  first_payment_month  (row key) │       │
│  │  frequency                     │   │  month_offset         (col key) │       │
│  │  monetary                      │   │  cohort_size                   │       │
│  │  r_score / f_score / m_score   │   │  retained_accounts             │       │
│  │  rfm_score  (e.g. "545")       │   │  retention_rate  (0.0 – 1.0)  │       │
│  │  segment   (e.g. "Champions")  │   │                                 │       │
│  └─────────────────────────────────┘   └─────────────────────────────────┘       │
│                                                                                  │
│  ┌─────────────────────────────────┐   ┌─────────────────────────────────┐       │
│  │  basket_pairs                   │   │  clv_analysis                    │       │
│  │                                │   │                                 │       │
│  │  antecedent                    │   │  account_id               (PK) │       │
│  │  consequent                    │   │  purchase_frequency            │       │
│  │  pair_count                    │   │  contributor_lifetime_months   │       │
│  │  pair_support   (0.0 – 1.0)    │   │  avg_gift_size                 │       │
│  │  pair_confidence (0.0 – 1.0)   │   │  revenue_per_contributor       │       │
│  │  pair_lift      (>1 = +assoc)  │   │  customer_lifetime_value       │       │
│  └─────────────────────────────────┘   │  engagement_tier (Plat/Gold/..)│       │
│                                        │  churn_probability             │       │
│                                        └─────────────────────────────────┘       │
│                                                                                  │
│  ┌─────────────────────────────────┐                                             │
│  │  exec_summary  (REPORTING)      │   Power BI uses these tables for:           │
│  │                                │                                             │
│  │  year                           │   rfm_analysis    → RFM page (treemap,      │
│  │  total_paid / total_pledged     │                     scatter, detail table)  │
│  │  paid_yoy_growth_pct            │   cohort_retention→ Cohort page (matrix)     │
│  │  contributors_yoy_growth_pct    │   basket_pairs    → Basket page (matrix,     │
│  │  avg_gift_yoy_growth_pct        │                     bar chart, detail table) │
│  │  total_campaigns / avg_roi      │   clv_analysis    → CLV page (KPIs, table)   │
│  │  churn_rate                     │   exec_summary    → Infographic (one-page)   │
│  └─────────────────────────────────┘                                             │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

## Testing & Quality

```bash
# Run all dbt tests (schema + custom)
dbt test

# Schema tests: not_null, unique, relationships, accepted_values
# Custom tests:
#   - assert_no_negative_amounts.sql
#   - assert_payment_date_after_close.sql
#   - assert_unique_pledge_id.sql
```

---

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/dbt_ci_cd.yml`) runs on every PR:

1. **dbt compile** - validate SQL syntax
2. **dbt test** - run all data quality tests against a dedicated CI schema
3. On merge to `main`: **dbt run** - deploy to production ANALYTICS schema
4. **dbt snapshot** - capture SCD Type 2 changes
5. **dbt docs generate** - publish updated documentation

---

## License

University assignment project - Swinburne University of Technology. For educational demonstration purposes.
