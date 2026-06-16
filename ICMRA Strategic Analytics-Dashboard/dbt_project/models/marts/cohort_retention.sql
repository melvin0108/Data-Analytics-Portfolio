-- ═══════════════════════════════════════════════════════════════════
-- Mart: cohort_retention
-- Source: int_pledges_enriched
-- Purpose: Pre-aggregated cohort retention matrix
-- Replaces: DAX measures [Cohort Size] + [Retention Rate] which
--           computed dynamically at query time using ALLEXCEPT
--
--   Output: one row per (cohort_month × month_offset) combination
--   Power BI: matrix visual with rows=first_payment_month,
--             columns=month_offset, values=retention_rate
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'analytics']
) }}

WITH paid_pledges AS (

    SELECT
        account_id,
        first_payment_month,
        payment_month,
        month_offset
    FROM {{ ref('int_pledges_enriched') }}
    WHERE payment_status = 'Paid'

),

-- ── Retained accounts per (cohort × offset) ───────────────────────
retained AS (

    SELECT
        first_payment_month,
        month_offset,
        COUNT(DISTINCT account_id) AS retained_accounts
    FROM paid_pledges
    GROUP BY first_payment_month, month_offset

),

-- ── Cohort size: distinct contributors at month_offset = 0 ────────
-- DAX: CALCULATE([Total Contributors], ALLEXCEPT(..., [First Payment Month]), [Month Offset]=0)
cohort_sizes AS (

    SELECT
        first_payment_month,
        COUNT(DISTINCT account_id) AS cohort_size
    FROM paid_pledges
    WHERE month_offset = 0
    GROUP BY first_payment_month

),

-- ── Final retention matrix ────────────────────────────────────────
cohort_retention AS (

    SELECT
        r.first_payment_month,
        r.month_offset,
        cs.cohort_size,

        r.retained_accounts,

        -- Retention rate: DAX DIVIDE([Total Contributors], [Cohort Size])
        ROUND(r.retained_accounts::FLOAT / cs.cohort_size, 4)
            AS retention_rate,

        -- Surrogate key
        {{ generate_surrogate_key([
            'r.first_payment_month',
            'r.month_offset'
        ]) }} AS cohort_key

    FROM retained r
    INNER JOIN cohort_sizes cs
        ON r.first_payment_month = cs.first_payment_month

)

SELECT * FROM cohort_retention
