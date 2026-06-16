-- ═══════════════════════════════════════════════════════════════════
-- ICMRA Analytics — Data Load (Excel → Snowflake RAW)
-- Loads ICMRA Dataset 2019-2025.xlsx into raw landing tables
-- Run as ICMRA_ETL_ROLE
-- ═══════════════════════════════════════════════════════════════════

USE DATABASE ICMRA_DB;
USE SCHEMA RAW;

-- ── Step 1: Create Internal Stage for Excel Upload ────────────────

CREATE OR REPLACE STAGE icmra_source_stage
    DIRECTORY = ( ENABLE = TRUE )
    COMMENT = 'Internal stage for ICMRA source Excel file uploads';

-- ── Step 2: Upload the source file ────────────────────────────────
-- Run from terminal (Snowflake CLI or Snowsight UI):
--
--   snowsql -q "PUT file:///path/to/ICMRA_Dataset_2019-2025.xlsx @icmra_source_stage AUTO_COMPRESS=TRUE"
--
-- Or via Snowsight: Databases → ICMRA_DB → RAW → Stages → ICMSRA_SOURCE_STAGE → Upload

-- ── Step 3: Create File Format for CSV (post-Excel conversion) ────
-- Snowflake cannot directly parse .xlsx. Options:
--   A) Convert Excel sheets to CSV first, then COPY INTO
--   B) Use Snowpark Python to read .xlsx directly
--
-- Below assumes CSV export (most reliable for presentation):

CREATE OR REPLACE FILE FORMAT icmra_csv_format
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
    NULL_IF = ('NULL', '', 'N/A')
    COMMENT = 'CSV format for ICMRA source data exports';

-- ── Step 4: COPY INTO Raw Tables ──────────────────────────────────
-- After converting Excel sheets to CSV and uploading to stage:

-- Load pledges (Sheet: Medical Research Grant Appeal)
COPY INTO raw_medical_research_grant_appeal (
    pledge_id,
    account_id,
    campaign_id,
    cont_type_id,
    referral_source,
    appeal_close_date,
    payment_date,
    pledge_pay_amount
)
FROM (
    SELECT
        $1,  -- pledge_id
        $2,  -- account_id
        $3,  -- campaign_id
        $4,  -- cont_type_id
        $5,  -- referral_source
        TRY_TO_DATE($6, 'YYYY-MM-DD'),  -- appeal_close_date
        IFF($7 = '', NULL, TRY_TO_DATE($7, 'YYYY-MM-DD')),  -- payment_date (nullable)
        TRY_TO_NUMBER($8, 15, 2)  -- pledge_pay_amount
    FROM @icmra_source_stage/medical_research_grant_appeal.csv
)
FILE_FORMAT = (FORMAT_NAME = 'icmra_csv_format')
ON_ERROR = 'ABORT_STATEMENT'
PURGE = TRUE;

-- Load campaigns (Sheet: MRA Campaign)
COPY INTO raw_mra_campaign (
    campaign_code,
    campaign_name,
    research_area,
    campaign_type,
    appeal_category,
    priority_level,
    target_amount,
    campaign_budget,
    channel_focus,
    campaign_start_date,
    campaign_end_date
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6,
        TRY_TO_NUMBER($7, 15, 2),
        TRY_TO_NUMBER($8, 15, 2),
        $9,
        TRY_TO_DATE($10, 'YYYY-MM-DD'),
        TRY_TO_DATE($11, 'YYYY-MM-DD')
    FROM @icmra_source_stage/mra_campaign.csv
)
FILE_FORMAT = (FORMAT_NAME = 'icmra_csv_format')
ON_ERROR = 'ABORT_STATEMENT'
PURGE = TRUE;

-- Load contributions (Sheet: Contribution)
COPY INTO raw_contribution (
    contribution_id,
    contribution_type,
    contribution_group
)
FROM (
    SELECT $1, $2, $3
    FROM @icmra_source_stage/contribution.csv
)
FILE_FORMAT = (FORMAT_NAME = 'icmra_csv_format')
ON_ERROR = 'ABORT_STATEMENT'
PURGE = TRUE;

-- Load accounts (Sheet: Account)
COPY INTO raw_account (
    account_code,
    account_name,
    contact_person,
    account_type,
    country,
    region,
    account_segment,
    preferred_referral_source,
    funding_capacity_band,
    account_since,
    organisation_size_band
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9,
        TRY_TO_DATE($10, 'YYYY-MM-DD'),
        $11
    FROM @icmra_source_stage/account.csv
)
FILE_FORMAT = (FORMAT_NAME = 'icmra_csv_format')
ON_ERROR = 'ABORT_STATEMENT'
PURGE = TRUE;

-- ── Step 5: Validate Row Counts ───────────────────────────────────

SELECT 'raw_medical_research_grant_appeal' AS table_name, COUNT(*) AS row_count FROM raw_medical_research_grant_appeal
UNION ALL
SELECT 'raw_mra_campaign', COUNT(*) FROM raw_mra_campaign
UNION ALL
SELECT 'raw_contribution', COUNT(*) FROM raw_contribution
UNION ALL
SELECT 'raw_account', COUNT(*) FROM raw_account
ORDER BY table_name;

-- ── Alternative: Snowpark Python for Direct Excel Loading ──────────
-- For production, use Snowpark Python to read .xlsx directly:
--
-- import snowflake.snowpark as snowpark
-- import pandas as pd
--
-- def load_excel(session: snowpark.Session):
--     df = pd.read_excel('ICMRA Dataset 2019-2025.xlsx', sheet_name='Medical Research Grant Appeal')
--     session.write_pandas(df, 'RAW_MEDICAL_RESEARCH_GRANT_APPEAL', auto_create_table=True, overwrite=True)
--     return session.sql("SELECT COUNT(*) FROM RAW.RAW_MEDICAL_RESEARCH_GRANT_APPEAL").collect()
