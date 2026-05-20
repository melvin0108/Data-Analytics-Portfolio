-- ═══════════════════════════════════════════════════════════════════
-- Intermediate Model: int_account_activity
-- Source: int_pledges_enriched
-- Purpose: Per-account aggregated activity metrics used by
--          dim_account (churn flag), rfm_analysis, and clv_analysis
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['intermediate']
) }}

WITH pledges AS (

    SELECT * FROM {{ ref('int_pledges_enriched') }}

),

account_activity AS (

    SELECT
        account_id,

        -- ── Recency ────────────────────────────────────────────────
        -- Days since last payment (lower = more recent)
        DATEDIFF('day', MAX(payment_date), CURRENT_DATE()) AS recency_days,
        MAX(payment_date)                                   AS last_payment_date,

        -- ── Frequency ─────────────────────────────────────────────
        -- Count of distinct paid pledges
        COUNT(CASE WHEN payment_status = 'Paid' THEN pledge_id END)
            AS paid_pledge_count,

        -- Total pledge count (paid + unpaid)
        COUNT(pledge_id) AS total_pledge_count,

        -- ── Monetary ──────────────────────────────────────────────
        SUM(CASE WHEN payment_status = 'Paid' THEN pledge_pay_amount ELSE 0 END)
            AS total_paid_amount,

        SUM(pledge_pay_amount) AS total_pledged_amount,

        -- ── Timing ────────────────────────────────────────────────
        MIN(CASE WHEN payment_status = 'Paid' THEN payment_date END)
            AS first_payment_date,

        MAX(payment_date) AS last_payment_date,

        -- ── Average Days to Pay ───────────────────────────────────
        AVG(CASE WHEN days_to_pay IS NOT NULL THEN days_to_pay END)
            AS avg_days_to_pay,

        -- ── Engagement span ───────────────────────────────────────
        DATEDIFF('month',
            MIN(CASE WHEN payment_status = 'Paid' THEN payment_date END),
            MAX(payment_date)
        ) AS active_months,

        -- ── Campaign diversity ────────────────────────────────────
        COUNT(DISTINCT campaign_id) AS distinct_campaigns,

        -- ── Contribution type diversity ───────────────────────────
        COUNT(DISTINCT cont_type_id) AS distinct_contribution_types

    FROM pledges
    GROUP BY account_id

)

SELECT * FROM account_activity
