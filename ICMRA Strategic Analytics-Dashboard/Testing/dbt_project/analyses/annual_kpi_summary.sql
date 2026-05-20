-- ═══════════════════════════════════════════════════════════════════
-- Analysis: annual_kpi_summary
-- Purpose: Ad-hoc query — annual fundraising performance dashboard
-- Run with: dbt run-operation {nothing} --Analyses aren't run directly;
--           use `dbt compile` then copy SQL, or run in Snowsight.
-- ═══════════════════════════════════════════════════════════════════

SELECT
    d.year,

    -- Revenue
    SUM(CASE WHEN p.payment_status = 'Paid' THEN p.pledge_pay_amount ELSE 0 END)
        AS total_paid,
    SUM(p.pledge_pay_amount)
        AS total_pledged,

    -- Volume
    COUNT(DISTINCT p.pledge_id)                       AS total_pledges,
    COUNT(DISTINCT CASE WHEN p.payment_status = 'Paid'
        THEN p.pledge_id END)                         AS paid_pledges,
    COUNT(DISTINCT p.account_id)                       AS unique_contributors,

    -- Efficiency
    ROUND(SUM(CASE WHEN p.payment_status = 'Paid'
        THEN p.pledge_pay_amount ELSE 0 END)
        / NULLIF(COUNT(DISTINCT CASE WHEN p.payment_status = 'Paid'
        THEN p.pledge_id END), 0), 2)                 AS avg_gift_size,
    ROUND(AVG(CASE WHEN p.days_to_pay IS NOT NULL
        THEN p.days_to_pay END), 1)                   AS avg_days_to_pay,

    -- Conversion
    ROUND(
        COUNT(DISTINCT CASE WHEN p.payment_status = 'Paid' THEN p.pledge_id END)::FLOAT
        / NULLIF(COUNT(DISTINCT p.pledge_id), 0),
    4)                                                AS pledge_conversion_rate

FROM {{ ref('dim_date') }} d
LEFT JOIN {{ ref('fct_pledges') }} p
    ON d.date = p.payment_date_key
WHERE d.date BETWEEN '2019-01-01' AND '2025-12-31'
GROUP BY d.year
ORDER BY d.year
