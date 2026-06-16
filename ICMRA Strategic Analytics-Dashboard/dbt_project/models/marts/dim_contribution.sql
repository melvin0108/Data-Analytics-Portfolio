-- ═══════════════════════════════════════════════════════════════════
-- Mart: dim_contribution
-- Source: stg_contributions
-- Purpose: Contribution type dimension (pass-through with surrogate key)
-- Replaces: Contribution source table
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'dimension']
) }}

WITH contributions AS (

    SELECT * FROM {{ ref('stg_contributions') }}

),

dim_contribution AS (

    SELECT
        contribution_id,
        contribution_type,
        contribution_group,

        -- Surrogate key
        {{ generate_surrogate_key(['contribution_id']) }} AS contribution_key

    FROM contributions

)

SELECT * FROM dim_contribution
