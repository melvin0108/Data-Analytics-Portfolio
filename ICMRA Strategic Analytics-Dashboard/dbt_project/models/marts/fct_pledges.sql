-- ═══════════════════════════════════════════════════════════════════
-- Mart: fct_pledges
-- Source: int_pledges_enriched
-- Purpose: Central fact table — the single source of truth for all
--          pledge/payment analytics consumed by Power BI
-- Replaces: Medical Research Grant Appeal (8 source + 6 DAX calc columns)
-- Materialization: Incremental (only new/changed rows processed)
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='incremental',
    unique_key='pledge_id',
    cluster_by=['payment_date', 'account_id'],
    tags=['marts', 'fact']
) }}

WITH enriched AS (

    SELECT * FROM {{ ref('int_pledges_enriched') }}

),

fct_pledges AS (

    SELECT
        -- ── Keys ──────────────────────────────────────────────────
        pledge_id,
        pledge_key,

        -- Foreign keys (match dim_ primary keys)
        account_id,
        campaign_id,
        cont_type_id,

        -- ── Date Foreign Keys ─────────────────────────────────────
        -- Payment date links to dim_date (active relationship)
        payment_date              AS payment_date_key,

        -- Appeal close date stored for analysis, linked via dim_date
        -- when USERELATIONSHIP needed (handled in PBI)
        appeal_close_date,

        -- ── Attributes ────────────────────────────────────────────
        referral_source,

        -- ── Measures (pre-computed from DAX calc columns) ─────────
        pledge_pay_amount,
        payment_status,           -- 'Paid' | 'Pledged-Unpaid'

        -- ── Cohort Fields (replaces DAX calc columns) ─────────────
        first_payment_date,
        first_payment_month,      -- Cohort row key
        payment_month,
        month_offset,             -- Cohort column key

        -- ── Derived Metrics (replaces DAX calc columns) ───────────
        days_to_pay,

        -- ── Metadata ──────────────────────────────────────────────
        _loaded_at,
        CURRENT_TIMESTAMP()       AS _updated_at

    FROM enriched

    {% if is_incremental() %}
    -- Incremental: only process rows newer than max existing _loaded_at
    WHERE _loaded_at > (
        SELECT MAX(_loaded_at) FROM {{ this }}
    )
    {% endif %}

)

SELECT * FROM fct_pledges
