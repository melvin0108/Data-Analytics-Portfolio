-- ═══════════════════════════════════════════════════════════════════
-- Mart: dim_account
-- Source: stg_accounts + int_account_activity
-- Purpose: Account dimension with pre-computed churn flag
-- Replaces: Account source table + DAX Churn Flag calculated column
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'dimension']
) }}

WITH accounts AS (

    SELECT * FROM {{ ref('stg_accounts') }}

),

activity AS (

    SELECT * FROM {{ ref('int_account_activity') }}

),

dim_account AS (

    SELECT
        a.account_code,
        a.account_name,
        a.contact_person,
        a.account_type,
        a.country,
        a.region,
        a.account_segment,
        a.preferred_referral_source,
        a.funding_capacity_band,
        a.organisation_size_band,
        a.account_since,
        a.account_tenure_months,

        -- ── Pre-computed activity metrics ─────────────────────────
        act.last_payment_date,
        act.recency_days,
        act.paid_pledge_count,
        act.total_paid_amount,
        act.avg_days_to_pay,

        -- ── Churn Flag (replaces DAX calculated column) ───────────
        -- DAX: IFF(DATEDIFF('month', last_payment, TODAY()) > 12, 1, 0)
        IFF(
            act.last_payment_date IS NULL
            OR DATEDIFF('month', act.last_payment_date, CURRENT_DATE())
                > {{ var('churn_inactive_months') }},
            1, 0
        ) AS churn_flag,

        -- ── Derived: Churn label ──────────────────────────────────
        IFF(
            act.last_payment_date IS NULL
            OR DATEDIFF('month', act.last_payment_date, CURRENT_DATE())
                > {{ var('churn_inactive_months') }},
            'Churned', 'Active'
        ) AS account_status,

        -- ── Surrogate key ─────────────────────────────────────────
        {{ generate_surrogate_key(['a.account_code']) }} AS account_key

    FROM accounts a
    LEFT JOIN activity act
        ON a.account_code = act.account_id

)

SELECT * FROM dim_account
