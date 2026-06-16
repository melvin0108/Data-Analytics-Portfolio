-- ═══════════════════════════════════════════════════════════════════
-- Snapshot: snap_pledges
-- Purpose: SCD Type 2 change tracking on fct_pledges
--          Captures when pledges transition from "Pledged-Unpaid" → "Paid"
--          and tracks amount changes over time
-- Run:     dbt snapshot
-- ═══════════════════════════════════════════════════════════════════

{% snapshot snap_pledges %}

{{
    config(
        target_schema='ANALYTICS',
        strategy='timestamp',
        unique_key='pledge_id',
        updated_at='_loaded_at',
        invalidate_hard_deletes=True
    )
}}

SELECT
    pledge_id,
    account_id,
    campaign_id,
    cont_type_id,
    payment_status,
    pledge_pay_amount,
    payment_date_key AS payment_date,
    appeal_close_date,
    days_to_pay,
    _loaded_at
FROM {{ ref('fct_pledges') }}

{% endsnapshot %}
