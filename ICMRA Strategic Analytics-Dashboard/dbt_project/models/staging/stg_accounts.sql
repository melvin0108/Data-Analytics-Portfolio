-- ═══════════════════════════════════════════════════════════════════
-- Staging Model: stg_accounts
-- Source: RAW.raw_account
-- Purpose: Type casting, column renaming, tenure calculation
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['staging', 'dimension']
) }}

WITH source AS (

    SELECT * FROM {{ source('icmra_raw', 'raw_account') }}

),

renamed AS (

    SELECT
        -- Primary key
        account_code::VARCHAR(50)                     AS account_code,

        -- Identity
        TRIM(account_name)::VARCHAR(200)              AS account_name,
        TRIM(contact_person)::VARCHAR(200)            AS contact_person,

        -- Classification
        TRIM(account_type)::VARCHAR(50)               AS account_type,
        TRIM(country)::VARCHAR(100)                   AS country,
        TRIM(region)::VARCHAR(100)                    AS region,
        TRIM(account_segment)::VARCHAR(50)            AS account_segment,
        TRIM(preferred_referral_source)::VARCHAR(100) AS preferred_referral_source,
        TRIM(funding_capacity_band)::VARCHAR(50)      AS funding_capacity_band,
        TRIM(organisation_size_band)::VARCHAR(50)     AS organisation_size_band,

        -- Dates
        account_since::DATE                           AS account_since,

        -- Derived: account tenure in months (as of today)
        DATEDIFF('month', account_since, CURRENT_DATE()) AS account_tenure_months,

        -- Metadata
        _loaded_at

    FROM source

)

SELECT * FROM renamed
