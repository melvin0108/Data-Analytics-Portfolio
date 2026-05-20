-- ═══════════════════════════════════════════════════════════════════
-- ICMRA Analytics — Raw Landing Tables
-- Exact replica of source Excel structure (VARCHAR staging for safety)
-- Run as ICMRA_ETL_ROLE
-- ═══════════════════════════════════════════════════════════════════

USE DATABASE ICMRA_DB;
USE SCHEMA RAW;

-- ── Fact Table: Pledge Transactions ───────────────────────────────

CREATE OR REPLACE TABLE raw_medical_research_grant_appeal (
    pledge_id            VARCHAR(50)   NOT NULL  COMMENT 'Unique pledge identifier (PK)',
    account_id           VARCHAR(50)             COMMENT 'FK → Account dimension',
    campaign_id          VARCHAR(50)             COMMENT 'FK → Campaign dimension',
    cont_type_id         VARCHAR(50)             COMMENT 'FK → Contribution type dimension',
    referral_source      VARCHAR(100)            COMMENT 'Referral channel source',
    appeal_close_date    DATE                    COMMENT 'Date the appeal period closed',
    payment_date         DATE                    COMMENT 'Date payment was received (NULL = unpaid)',
    pledge_pay_amount    NUMBER(15,2)            COMMENT 'Pledge or payment amount in USD',
    _loaded_at           TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    _source_file         VARCHAR(255) DEFAULT 'ICMRA Dataset 2019-2025.xlsx'
);

-- ── Dimension: Campaign ───────────────────────────────────────────

CREATE OR REPLACE TABLE raw_mra_campaign (
    campaign_code        VARCHAR(50)   NOT NULL  COMMENT 'Unique campaign code (PK)',
    campaign_name        VARCHAR(200)            COMMENT 'Human-readable campaign name',
    research_area        VARCHAR(100)            COMMENT 'Medical research domain',
    campaign_type        VARCHAR(50)             COMMENT 'Campaign classification',
    appeal_category      VARCHAR(50)             COMMENT 'Fundraising appeal category',
    priority_level       VARCHAR(20)             COMMENT 'Campaign priority tier',
    target_amount        NUMBER(15,2)            COMMENT 'Fundraising target in USD',
    campaign_budget      NUMBER(15,2)            COMMENT 'Allocated campaign budget in USD',
    channel_focus        VARCHAR(50)             COMMENT 'Primary marketing channel',
    campaign_start_date  DATE                    COMMENT 'Campaign launch date',
    campaign_end_date    DATE                    COMMENT 'Campaign closing date',
    _loaded_at           TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file         VARCHAR(255) DEFAULT 'ICMRA Dataset 2019-2025.xlsx'
);

-- ── Dimension: Contribution Type ──────────────────────────────────

CREATE OR REPLACE TABLE raw_contribution (
    contribution_id      VARCHAR(50)   NOT NULL  COMMENT 'Contribution type code (PK)',
    contribution_type    VARCHAR(100)            COMMENT 'Contribution type description',
    contribution_group   VARCHAR(100)            COMMENT 'High-level contribution grouping',
    _loaded_at           TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file         VARCHAR(255) DEFAULT 'ICMRA Dataset 2019-2025.xlsx'
);

-- ── Dimension: Account / Contributor ──────────────────────────────

CREATE OR REPLACE TABLE raw_account (
    account_code                 VARCHAR(50)   NOT NULL  COMMENT 'Unique account code (PK)',
    account_name                 VARCHAR(200)            COMMENT 'Organisation or individual name',
    contact_person               VARCHAR(200)            COMMENT 'Primary contact name',
    account_type                 VARCHAR(50)             COMMENT 'Individual / Organisation / Government',
    country                      VARCHAR(100)            COMMENT 'Country of residence',
    region                       VARCHAR(100)            COMMENT 'Geographic region',
    account_segment              VARCHAR(50)             COMMENT 'Marketing segment classification',
    preferred_referral_source    VARCHAR(100)            COMMENT 'Preferred engagement channel',
    funding_capacity_band        VARCHAR(50)             COMMENT 'Estimated giving capacity range',
    account_since                DATE                    COMMENT 'Date account was first registered',
    organisation_size_band       VARCHAR(50)             COMMENT 'Organisation size category',
    _loaded_at                   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source_file                 VARCHAR(255) DEFAULT 'ICMRA Dataset 2019-2025.xlsx'
);

-- ── Constraints ───────────────────────────────────────────────────

ALTER TABLE raw_medical_research_grant_appeal ADD CONSTRAINT pk_pledge_id PRIMARY KEY (pledge_id);
ALTER TABLE raw_mra_campaign                 ADD CONSTRAINT pk_campaign_code PRIMARY KEY (campaign_code);
ALTER TABLE raw_contribution                 ADD CONSTRAINT pk_contribution_id PRIMARY KEY (contribution_id);
ALTER TABLE raw_account                      ADD CONSTRAINT pk_account_code PRIMARY KEY (account_code);

-- ── Metadata ──────────────────────────────────────────────────────

COMMENT ON TABLE raw_medical_research_grant_appeal IS 'Fact table — pledge/payment transactions from ICMRA fundraising appeals 2019-2025';
COMMENT ON TABLE raw_mra_campaign                IS 'Dimension — campaign master data with targets, budgets, and channel focus';
COMMENT ON TABLE raw_contribution                IS 'Dimension — contribution type lookup (donation, grant, sponsorship, etc.)';
COMMENT ON TABLE raw_account                     IS 'Dimension — contributor account master data with demographics and capacity';
