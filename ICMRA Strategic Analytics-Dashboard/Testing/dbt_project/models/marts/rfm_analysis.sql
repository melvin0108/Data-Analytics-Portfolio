-- ═══════════════════════════════════════════════════════════════════
-- Mart: rfm_analysis
-- Source: int_account_activity + rfm_segment_mapping (seed)
-- Purpose: Per-account RFM (Recency/Frequency/Monetary) segmentation
-- Replaces: DAX calculated tables RFM + Dim_RankRFM (2 tables → 1)
--
--   RFM scoring uses NTILE(5) quintile windows:
--     R: 1=most recent → 5=least recent (lower = better)
--     F: 1=least frequent → 5=most frequent (higher = better)
--     M: 1=lowest spend → 5=highest spend (higher = better)
--     RFM Score: R*100 + F*10 + M (range 111-555)
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'analytics']
) }}

WITH activity AS (

    SELECT * FROM {{ ref('int_account_activity') }}

),

-- Only accounts with at least one paid pledge
paid_accounts AS (

    SELECT
        account_id,
        recency_days,
        paid_pledge_count  AS frequency,
        total_paid_amount  AS monetary
    FROM activity
    WHERE paid_pledge_count > 0

),

-- ── NTILE Quintile Scoring ────────────────────────────────────────
scored AS (

    SELECT
        account_id,
        recency_days,
        frequency,
        monetary,

        -- Recency score (INVERTED: lower recency = higher score)
        NTILE({{ var('rfm_n_tile') }}) OVER (ORDER BY recency_days DESC)  AS r_score,

        -- Frequency score (higher frequency = higher score)
        NTILE({{ var('rfm_n_tile') }}) OVER (ORDER BY frequency ASC)      AS f_score,

        -- Monetary score (higher spend = higher score)
        NTILE({{ var('rfm_n_tile') }}) OVER (ORDER BY monetary ASC)       AS m_score

    FROM paid_accounts

),

-- ── Composite RFM Score ───────────────────────────────────────────
rfm_scored AS (

    SELECT
        account_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,

        -- Composite: 3-digit score (e.g. "545" = R:5, F:4, M:5)
        (r_score * 100 + f_score * 10 + m_score)::VARCHAR AS rfm_score,

        -- String combo for segment mapping
        r_score::VARCHAR || f_score::VARCHAR || m_score::VARCHAR AS rfm_combo

    FROM scored

),

-- ── Segment Mapping (joins to seed file) ──────────────────────────
segment_mapping AS (

    SELECT * FROM {{ ref('rfm_segment_mapping') }}

),

rfm_analysis AS (

    SELECT
        r.account_id,
        r.recency_days,
        r.frequency,
        r.monetary,
        r.r_score,
        r.f_score,
        r.m_score,
        r.rfm_score,
        r.rfm_combo,

        -- Segment from lookup table
        COALESCE(s.segment, 'Unclassified')  AS segment,
        COALESCE(s.description, 'No segment description') AS segment_description,
        COALESCE(s.action, 'Review engagement') AS recommended_action,

        -- Surrogate key
        {{ generate_surrogate_key(['r.account_id']) }} AS rfm_key

    FROM rfm_scored r
    LEFT JOIN segment_mapping s
        ON r.rfm_combo = s.rfm_score

)

SELECT * FROM rfm_analysis
