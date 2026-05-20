-- ═══════════════════════════════════════════════════════════════════
-- Staging Model: stg_campaigns
-- Source: RAW.raw_mra_campaign
-- Purpose: Type casting, column renaming, derived campaign duration
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['staging', 'dimension']
) }}

WITH source AS (

    SELECT * FROM {{ source('icmra_raw', 'raw_mra_campaign') }}

),

renamed AS (

    SELECT
        -- Primary key
        campaign_code::VARCHAR(50)              AS campaign_code,

        -- Descriptors
        TRIM(campaign_name)::VARCHAR(200)       AS campaign_name,
        TRIM(research_area)::VARCHAR(100)       AS research_area,
        TRIM(campaign_type)::VARCHAR(50)        AS campaign_type,
        TRIM(appeal_category)::VARCHAR(50)      AS appeal_category,

        -- Classification
        UPPER(TRIM(priority_level))::VARCHAR(20) AS priority_level,

        -- Financials
        target_amount::NUMBER(15,2)             AS target_amount,
        campaign_budget::NUMBER(15,2)           AS campaign_budget,

        -- Channel
        TRIM(channel_focus)::VARCHAR(50)        AS channel_focus,

        -- Dates
        campaign_start_date::DATE               AS campaign_start_date,
        campaign_end_date::DATE                 AS campaign_end_date,

        -- Derived: campaign duration in days
        DATEDIFF('day', campaign_start_date, campaign_end_date)
                                                AS campaign_duration_days,

        -- Metadata
        _loaded_at

    FROM source

)

SELECT * FROM renamed
