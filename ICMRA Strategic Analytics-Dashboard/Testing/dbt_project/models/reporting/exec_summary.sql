-- ═══════════════════════════════════════════════════════════════════
-- Reporting: exec_summary
-- Source: All mart tables
-- Purpose: Board-level KPI summary (single row per year)
--          Powers the Executive Infographic deliverable
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['reporting']
) }}

WITH pledges AS (

    SELECT * FROM {{ ref('fct_pledges') }}

),

campaigns AS (

    SELECT * FROM {{ ref('dim_campaign') }}

),

accounts AS (

    SELECT * FROM {{ ref('dim_account') }}

),

annual AS (

    SELECT
        d.year,

        -- ── Revenue Metrics ───────────────────────────────────────
        SUM(CASE WHEN p.payment_status = 'Paid' THEN p.pledge_pay_amount ELSE 0 END)
            AS total_paid,
        SUM(p.pledge_pay_amount)
            AS total_pledged,

        -- ── Volume Metrics ────────────────────────────────────────
        COUNT(DISTINCT p.pledge_id)
            AS total_pledges,
        COUNT(DISTINCT CASE WHEN p.payment_status = 'Paid' THEN p.pledge_id END)
            AS paid_pledges,
        COUNT(DISTINCT p.account_id)
            AS total_contributors,

        -- ── Efficiency Metrics ────────────────────────────────────
        ROUND(
            SUM(CASE WHEN p.payment_status = 'Paid' THEN p.pledge_pay_amount ELSE 0 END)
            / NULLIF(
                COUNT(DISTINCT CASE WHEN p.payment_status = 'Paid' THEN p.pledge_id END),
                0
            ),
            2
        ) AS avg_gift_size,

        -- Pledge Conversion %
        ROUND(
            COUNT(DISTINCT CASE WHEN p.payment_status = 'Paid' THEN p.pledge_id END)::FLOAT
            / NULLIF(COUNT(DISTINCT p.pledge_id), 0),
            4
        ) AS pledge_conversion_pct,

        -- Avg Days to Pay
        ROUND(AVG(CASE WHEN p.days_to_pay IS NOT NULL THEN p.days_to_pay END), 1)
            AS avg_days_to_pay

    FROM {{ ref('dim_date') }} d
    LEFT JOIN pledges p
        ON d.date = p.payment_date_key
    WHERE d.date BETWEEN '{{ var("start_date") }}'::DATE AND '{{ var("end_date") }}'::DATE
    GROUP BY d.year

),

-- ── YoY Growth ────────────────────────────────────────────────────
with_growth AS (

    SELECT
        a.year,
        a.total_paid,
        a.total_pledged,
        a.total_pledges,
        a.paid_pledges,
        a.total_contributors,
        a.avg_gift_size,
        a.pledge_conversion_pct,
        a.avg_days_to_pay,

        -- YoY growth
        ROUND((a.total_paid - prev.total_paid)::FLOAT / NULLIF(prev.total_paid, 0), 4)
            AS paid_yoy_growth_pct,
        ROUND((a.total_contributors - prev.total_contributors)::FLOAT / NULLIF(prev.total_contributors, 0), 4)
            AS contributors_yoy_growth_pct,
        ROUND((a.avg_gift_size - prev.avg_gift_size)::FLOAT / NULLIF(prev.avg_gift_size, 0), 4)
            AS avg_gift_yoy_growth_pct

    FROM annual a
    LEFT JOIN annual prev ON a.year = prev.year + 1

),

-- ── Campaign Summary per Year ─────────────────────────────────────
campaign_summary AS (

    SELECT
        d.year,
        COUNT(DISTINCT c.campaign_code) AS total_campaigns,
        SUM(c.target_amount)            AS total_target,
        SUM(c.campaign_budget)          AS total_campaign_budget,
        ROUND(AVG(c.roi), 4)            AS avg_roi,
        ROUND(AVG(c.target_achievement_pct), 4) AS avg_target_achievement
    FROM {{ ref('dim_date') }} d
    JOIN campaigns c
        ON d.year = YEAR(c.campaign_start_date)
    GROUP BY d.year

),

-- ── Churn Rate per Year ───────────────────────────────────────────
churn AS (

    SELECT
        YEAR(account_since) AS cohort_year,
        SUM(churn_flag)::FLOAT / COUNT(*) AS churn_rate
    FROM accounts
    GROUP BY YEAR(account_since)

)

SELECT
    g.year,
    g.total_paid,
    g.total_pledged,
    g.total_pledges,
    g.paid_pledges,
    g.total_contributors,
    g.avg_gift_size,
    g.pledge_conversion_pct,
    g.avg_days_to_pay,
    g.paid_yoy_growth_pct,
    g.contributors_yoy_growth_pct,
    g.avg_gift_yoy_growth_pct,
    cs.total_campaigns,
    cs.total_target,
    cs.total_campaign_budget,
    cs.avg_roi,
    cs.avg_target_achievement,
    ch.churn_rate

FROM with_growth g
LEFT JOIN campaign_summary cs ON g.year = cs.year
LEFT JOIN churn ch ON g.year = ch.cohort_year

ORDER BY g.year
