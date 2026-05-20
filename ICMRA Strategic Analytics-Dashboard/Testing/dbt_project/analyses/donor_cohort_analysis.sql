-- ═══════════════════════════════════════════════════════════════════
-- Analysis: donor_cohort_analysis
-- Purpose: Ad-hoc query — cohort retention heatmap data with
--          year-over-year donor retention comparison
-- ═══════════════════════════════════════════════════════════════════

SELECT
    cr.first_payment_month,
    cr.month_offset,
    cr.cohort_size,
    cr.retained_accounts,
    cr.retention_rate,

    -- Previous year cohort (same month_offset) for comparison
    LAG(cr.retention_rate) OVER (
        PARTITION BY cr.month_offset
        ORDER BY cr.first_payment_month
    ) AS prev_year_retention_rate,

    -- Retention rate delta vs prior year
    ROUND(
        cr.retention_rate - LAG(cr.retention_rate) OVER (
            PARTITION BY cr.month_offset
            ORDER BY cr.first_payment_month
        ),
        4
    ) AS retention_delta,

    -- Absolute retained accounts lost/gained vs prior year
    cr.retained_accounts - LAG(cr.retained_accounts) OVER (
        PARTITION BY cr.month_offset
        ORDER BY cr.first_payment_month
    ) AS retained_delta

FROM {{ ref('cohort_retention') }} cr
ORDER BY cr.first_payment_month, cr.month_offset
