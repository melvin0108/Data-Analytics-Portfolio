-- ═══════════════════════════════════════════════════════════════════
-- Mart: basket_pairs
-- Source: int_pledges_enriched
-- Purpose: Market basket association rules (support, confidence, lift)
-- Replaces: DAX calculated table BasketPairs + measures Pair Support,
--           Pair Confidence, Pair Lift
--
--   Logic: For each account, find all pairs of contribution types
--   co-occurring in paid pledges. Compute association rule metrics.
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'analytics']
) }}

WITH paid_pledges AS (

    SELECT
        account_id,
        cont_type_id
    FROM {{ ref('int_pledges_enriched') }}
    WHERE payment_status = 'Paid'

),

-- ── Unique (account, contribution_type) combinations ───────────────
account_contributions AS (

    SELECT DISTINCT
        account_id,
        cont_type_id
    FROM paid_pledges

),

-- ── Generate all ordered pairs (A < B to avoid duplicates) ────────
pairs AS (

    SELECT
        a.cont_type_id AS antecedent,
        b.cont_type_id AS consequent,
        COUNT(DISTINCT a.account_id) AS pair_count
    FROM account_contributions a
    INNER JOIN account_contributions b
        ON a.account_id = b.account_id
        AND a.cont_type_id < b.cont_type_id
    GROUP BY a.cont_type_id, b.cont_type_id

),

-- ── Per-type account counts (for confidence & lift denominators) ──
type_counts AS (

    SELECT
        cont_type_id,
        COUNT(DISTINCT account_id) AS account_count
    FROM account_contributions
    GROUP BY cont_type_id

),

-- ── Total unique accounts (for support denominator) ───────────────
total AS (

    SELECT COUNT(DISTINCT account_id) AS total_accounts
    FROM paid_pledges

),

-- ── Association rule metrics ──────────────────────────────────────
basket_pairs AS (

    SELECT
        p.antecedent,
        p.consequent,
        p.pair_count,
        t.total_accounts,

        -- ── Support: P(A ∩ B) = pair_count / total_accounts ──────
        -- DAX: DIVIDE(COUNTROWS(BasketPairs), [Total Contributors])
        ROUND(p.pair_count::FLOAT / t.total_accounts, 4)
            AS pair_support,

        -- ── Confidence: P(B|A) = pair_count / antecedent_count ───
        -- DAX: Accounts with both ÷ accounts with antecedent only
        ROUND(p.pair_count::FLOAT / ant.account_count, 4)
            AS pair_confidence,

        -- ── Lift: P(B|A) / P(B) ──────────────────────────────────
        -- DAX: DIVIDE([Pair Confidence], baseline P(consequent))
        ROUND(
            (p.pair_count::FLOAT / ant.account_count) /
            (con.account_count::FLOAT / t.total_accounts),
            4
        ) AS pair_lift,

        -- Surrogate key
        {{ generate_surrogate_key([
            'p.antecedent',
            'p.consequent'
        ]) }} AS basket_key

    FROM pairs p
    CROSS JOIN total t
    INNER JOIN type_counts ant
        ON p.antecedent = ant.cont_type_id
    INNER JOIN type_counts con
        ON p.consequent = con.cont_type_id

)

SELECT * FROM basket_pairs
ORDER BY pair_lift DESC
