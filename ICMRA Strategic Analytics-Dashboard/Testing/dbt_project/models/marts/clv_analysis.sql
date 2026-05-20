-- ═══════════════════════════════════════════════════════════════════
-- Mart: clv_analysis
-- Source: int_account_activity + int_pledges_enriched
-- Purpose: Per-account Customer Lifetime Value metrics
-- Replaces: DAX measures [Purchase Frequency], [Contributor Lifetime],
--           [Customer Lifetime Value], [Revenue per Contributor]
--
--   CLV Formula:
--     CLV = Avg Gift Size × Purchase Frequency × Contributor Lifetime (months)
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'analytics']
) }}

WITH activity AS (

    SELECT * FROM {{ ref('int_account_activity') }}

),

enriched AS (

    SELECT * FROM {{ ref('int_pledges_enriched') }}

),

-- ── Global dataset span (replaces DAX ALL() pattern) ──────────────
-- DAX: DATEDIFF(MINX(ALL(MRGA),[Payment Date]), MAXX(ALL(MRGA),[Payment Date]), MONTH)
dataset_span AS (

    SELECT
        DATEDIFF('month',
            MIN(payment_date),
            MAX(payment_date)
        ) AS contributor_lifetime_months
    FROM enriched
    WHERE payment_status = 'Paid'

),

-- ── Per-account CLV components ────────────────────────────────────
clv_analysis AS (

    SELECT
        act.account_id,

        -- ── Purchase Frequency ────────────────────────────────────
        -- DAX: DIVIDE([Paid Pledges], [Total Contributors])
        act.paid_pledge_count::FLOAT / NULLIFZERO(act.total_pledge_count)
            AS purchase_frequency,

        -- ── Contributor Lifetime ──────────────────────────────────
        -- Uses the global dataset span (same for all accounts)
        COALESCE(ds.contributor_lifetime_months, 0)
            AS contributor_lifetime_months,

        -- ── Average Gift Size ─────────────────────────────────────
        -- DAX: DIVIDE([Total Paid], [Paid Pledges])
        IFF(act.paid_pledge_count > 0,
            act.total_paid_amount::FLOAT / act.paid_pledge_count,
            0
        ) AS avg_gift_size,

        -- ── Revenue per Contributor ───────────────────────────────
        -- DAX: DIVIDE([Total Paid], [Total Contributors])
        act.total_paid_amount AS revenue_per_contributor,

        -- ── Customer Lifetime Value ───────────────────────────────
        -- DAX: [Avg Pledge Size] * [Purchase Frequency] * [Contributor Lifetime (m)]
        IFF(act.paid_pledge_count > 0,
            (act.total_paid_amount::FLOAT / act.paid_pledge_count)
            * (act.paid_pledge_count::FLOAT / NULLIFZERO(act.total_pledge_count))
            * COALESCE(ds.contributor_lifetime_months, 0),
            0
        ) AS customer_lifetime_value,

        -- ── Churn probability ─────────────────────────────────────
        IFF(
            act.last_payment_date IS NULL
            OR DATEDIFF('month', act.last_payment_date, CURRENT_DATE())
                > {{ var('churn_inactive_months') }},
            1.0, 0.0
        ) AS churn_probability,

        -- ── Engagement tier ───────────────────────────────────────
        CASE
            WHEN act.paid_pledge_count >= 10 AND act.total_paid_amount >= 50000
                THEN 'Platinum'
            WHEN act.paid_pledge_count >= 5 AND act.total_paid_amount >= 10000
                THEN 'Gold'
            WHEN act.paid_pledge_count >= 2
                THEN 'Silver'
            ELSE 'Bronze'
        END AS engagement_tier,

        -- Surrogate key
        {{ generate_surrogate_key(['act.account_id']) }} AS clv_key

    FROM activity act
    CROSS JOIN dataset_span ds

)

SELECT * FROM clv_analysis
