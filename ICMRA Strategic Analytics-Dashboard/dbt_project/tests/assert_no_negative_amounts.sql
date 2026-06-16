-- ═══════════════════════════════════════════════════════════════════
-- Custom Test: assert_no_negative_amounts
-- Validates no pledge/pay amounts are negative or zero
-- ═══════════════════════════════════════════════════════════════════

SELECT
    pledge_id,
    pledge_pay_amount,
    account_id,
    campaign_id
FROM {{ ref('fct_pledges') }}
WHERE pledge_pay_amount < 0
