-- ═══════════════════════════════════════════════════════════════════
-- Staging Model: stg_pledges
-- Source: RAW.raw_medical_research_grant_appeal
-- Purpose: Type casting, column renaming, null handling, dedup
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['staging', 'fact']
) }}

WITH source AS (

    SELECT * FROM {{ source('icmra_raw', 'raw_medical_research_grant_appeal') }}

),

deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pledge_id
            ORDER BY _loaded_at DESC
        ) AS _row_rank
    FROM source

),

renamed AS (

    SELECT
        -- Primary key
        pledge_id::VARCHAR(50)                AS pledge_id,

        -- Foreign keys
        account_id::VARCHAR(50)               AS account_id,
        campaign_id::VARCHAR(50)              AS campaign_id,
        cont_type_id::VARCHAR(50)             AS cont_type_id,

        -- Attributes
        TRIM(referral_source)::VARCHAR(100)   AS referral_source,

        -- Dates
        appeal_close_date::DATE               AS appeal_close_date,
        payment_date::DATE                    AS payment_date,

        -- Amounts
        pledge_pay_amount::NUMBER(15,2)       AS pledge_pay_amount,

        -- Metadata
        _loaded_at                            AS _loaded_at

    FROM deduplicated
    WHERE _row_rank = 1

)

SELECT * FROM renamed
