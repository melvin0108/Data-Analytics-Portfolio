-- ═══════════════════════════════════════════════════════════════════
-- Custom Test: assert_payment_date_after_close
-- Validates all payment dates are on or after the appeal close date
-- (a payment before the appeal closed would indicate a data quality issue)
-- ═══════════════════════════════════════════════════════════════════

SELECT
    pledge_id,
    account_id,
    appeal_close_date,
    payment_date_key AS payment_date,
    DATEDIFF('day', appeal_close_date, payment_date_key) AS days_difference
FROM {{ ref('fct_pledges') }}
WHERE payment_status = 'Paid'
  AND payment_date_key IS NOT NULL
  AND appeal_close_date IS NOT NULL
  AND payment_date_key < appeal_close_date
