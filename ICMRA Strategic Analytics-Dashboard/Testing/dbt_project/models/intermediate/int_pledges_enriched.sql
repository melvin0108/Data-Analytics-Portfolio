-- ═══════════════════════════════════════════════════════════════════
-- Intermediate Model: int_pledges_enriched
-- Source: stg_pledges + account first-payment aggregates
-- Purpose: Replaces all 6 DAX calculated columns in the fact table
--
--   DAX columns replaced:
--     • Payment Status       → IFF(payment_date IS NULL, ...)
--     • First Payment Date   → MIN(payment_date) OVER (PARTITION BY account_id)
--     • First Payment Month  → DATE_TRUNC('month', first_payment_date)
--     • Payment Month        → DATE_TRUNC('month', payment_date)
--     • Month Offset         → DATEDIFF between first_payment_month and payment_month
--     • Days to Pay          → DATEDIFF between appeal_close_date and payment_date
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['intermediate']
) }}

WITH pledges AS (

    SELECT * FROM {{ ref('stg_pledges') }}

),

-- Calculate first payment date per account (replaces DAX FIRSTNONBLANK)
account_first_payment AS (

    SELECT
        account_id,
        MIN(payment_date) AS first_payment_date
    FROM pledges
    WHERE payment_date IS NOT NULL
    GROUP BY account_id

),

enriched AS (

    SELECT
        p.pledge_id,
        p.account_id,
        p.campaign_id,
        p.cont_type_id,
        p.referral_source,
        p.appeal_close_date,
        p.payment_date,
        p.pledge_pay_amount,

        -- ── Calculated Column: Payment Status ─────────────────────
        -- DAX: IF(ISBLANK([Payment Date]), "Pledged-Unpaid", "Paid")
        IFF(p.payment_date IS NULL, 'Pledged-Unpaid', 'Paid')
            AS payment_status,

        -- ── Calculated Column: First Payment Date ─────────────────
        -- DAX: Earliest payment date per Account ID
        afp.first_payment_date,

        -- ── Calculated Column: First Payment Month (Cohort Row) ───
        -- DAX: STARTOFMONTH([First Payment Date])
        DATE_TRUNC('month', afp.first_payment_date)
            AS first_payment_month,

        -- ── Calculated Column: Payment Month ──────────────────────
        -- DAX: STARTOFMONTH([Payment Date])
        DATE_TRUNC('month', p.payment_date)
            AS payment_month,

        -- ── Calculated Column: Month Offset (Cohort Column) ───────
        -- DAX: DATEDIFF([First Payment Month], [Payment Month], MONTH)
        DATEDIFF('month',
            DATE_TRUNC('month', afp.first_payment_date),
            DATE_TRUNC('month', p.payment_date)
        ) AS month_offset,

        -- ── Calculated Column: Days to Pay ────────────────────────
        -- DAX: DATEDIFF([Appeal Close Date], [Payment Date], DAY)
        IFF(
            p.payment_date IS NOT NULL AND p.appeal_close_date IS NOT NULL,
            DATEDIFF('day', p.appeal_close_date, p.payment_date),
            NULL
        ) AS days_to_pay,

        -- ── Surrogate key for downstream joins ─────────────────────
        {{ generate_surrogate_key(['p.pledge_id']) }} AS pledge_key,

        p._loaded_at

    FROM pledges p
    LEFT JOIN account_first_payment afp
        ON p.account_id = afp.account_id

)

SELECT * FROM enriched
