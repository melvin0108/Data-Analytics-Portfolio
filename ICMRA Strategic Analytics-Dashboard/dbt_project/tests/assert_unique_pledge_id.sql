-- ═══════════════════════════════════════════════════════════════════
-- Custom Test: assert_unique_pledge_id
-- Validates pledge_id uniqueness (surrogate key integrity check)
-- ═══════════════════════════════════════════════════════════════════

SELECT
    pledge_id,
    COUNT(*) AS duplicate_count
FROM {{ ref('fct_pledges') }}
GROUP BY pledge_id
HAVING COUNT(*) > 1
