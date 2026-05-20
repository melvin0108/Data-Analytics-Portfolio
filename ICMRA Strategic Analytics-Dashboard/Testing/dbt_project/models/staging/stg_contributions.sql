-- ═══════════════════════════════════════════════════════════════════
-- Staging Model: stg_contributions
-- Source: RAW.raw_contribution
-- Purpose: Type casting, column renaming for contribution type lookup
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['staging', 'dimension']
) }}

WITH source AS (

    SELECT * FROM {{ source('icmra_raw', 'raw_contribution') }}

),

renamed AS (

    SELECT
        -- Primary key
        contribution_id::VARCHAR(50)        AS contribution_id,

        -- Descriptors
        TRIM(contribution_type)::VARCHAR(100) AS contribution_type,
        TRIM(contribution_group)::VARCHAR(100) AS contribution_group,

        -- Metadata
        _loaded_at

    FROM source

)

SELECT * FROM renamed
