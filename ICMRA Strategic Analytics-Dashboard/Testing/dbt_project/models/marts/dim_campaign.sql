-- ═══════════════════════════════════════════════════════════════════
-- Mart: dim_campaign
-- Source: stg_campaigns + int_pledges_enriched (aggregated)
-- Purpose: Campaign dimension with pre-computed performance metrics
-- Replaces: MRA Campaign source table + DAX measures (ROI, Target %)
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'dimension']
) }}

WITH campaigns AS (

    SELECT * FROM {{ ref('stg_campaigns') }}

),

campaign_performance AS (

    SELECT
        campaign_id,
        COUNT(DISTINCT pledge_id)           AS total_pledges,
        COUNT(DISTINCT CASE
            WHEN payment_status = 'Paid' THEN pledge_id END
        )                                    AS paid_pledges,
        SUM(pledge_pay_amount)               AS total_pledged,
        SUM(CASE
            WHEN payment_status = 'Paid' THEN pledge_pay_amount ELSE 0
        END)                                  AS total_paid,
        COUNT(DISTINCT account_id)           AS total_contributors
    FROM {{ ref('int_pledges_enriched') }}
    GROUP BY campaign_id

),

dim_campaign AS (

    SELECT
        c.campaign_code,
        c.campaign_name,
        c.research_area,
        c.campaign_type,
        c.appeal_category,
        c.priority_level,
        c.channel_focus,
        c.campaign_start_date,
        c.campaign_end_date,
        c.campaign_duration_days,

        -- ── Campaign Financial Targets ────────────────────────────
        c.target_amount,
        c.campaign_budget,

        -- ── Pre-computed Performance (replaces DAX measures) ──────
        COALESCE(cp.total_pledges, 0)       AS actual_total_pledges,
        COALESCE(cp.paid_pledges, 0)        AS actual_paid_pledges,
        COALESCE(cp.total_pledged, 0)       AS actual_total_pledged,
        COALESCE(cp.total_paid, 0)          AS actual_total_paid,
        COALESCE(cp.total_contributors, 0)  AS actual_total_contributors,

        -- ── Pre-computed KPIs (replaces DAX measures) ─────────────
        -- Target Achievement %: DAX DIVIDE([Total Paid], [Total Target])
        IFF(c.target_amount > 0,
            ROUND(cp.total_paid / c.target_amount, 4),
            NULL
        ) AS target_achievement_pct,

        -- ROI: DAX DIVIDE([Total Paid] - [Total Campaign Budget], [Total Campaign Budget])
        IFF(c.campaign_budget > 0,
            ROUND((cp.total_paid - c.campaign_budget) / c.campaign_budget, 4),
            NULL
        ) AS roi,

        -- Pledge Conversion %: DAX DIVIDE([Paid Pledges], [Total Pledges])
        IFF(cp.total_pledges > 0,
            ROUND(cp.paid_pledges::FLOAT / cp.total_pledges, 4),
            NULL
        ) AS pledge_conversion_pct,

        -- Surrogate key
        {{ generate_surrogate_key(['c.campaign_code']) }} AS campaign_key

    FROM campaigns c
    LEFT JOIN campaign_performance cp
        ON c.campaign_code = cp.campaign_id

)

SELECT * FROM dim_campaign
