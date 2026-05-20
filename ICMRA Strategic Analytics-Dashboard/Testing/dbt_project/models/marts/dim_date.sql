-- ═══════════════════════════════════════════════════════════════════
-- Mart: dim_date
-- Purpose: Date dimension 2019-01-01 to 2025-12-31
-- Replaces: DAX calculated table Dim_Date
-- Generation: Uses Snowflake built-in date spine (no external macros)
-- ═══════════════════════════════════════════════════════════════════

{{ config(
    materialized='table',
    tags=['marts', 'dimension']
) }}

WITH date_spine AS (

    SELECT
        DATEADD('day',
            ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1,
            '{{ var("start_date") }}'::DATE
        ) AS date_key
    FROM TABLE(GENERATOR(ROWCOUNT => 2557))  -- 2019-01-01 to 2025-12-31 = 2557 days

),

dim_date AS (

    SELECT
        date_key::DATE                                   AS date,

        -- ── Calendar Attributes ───────────────────────────────────
        YEAR(date_key)                                    AS year,
        QUARTER(date_key)                                 AS quarter,
        MONTH(date_key)                                   AS month_num,
        DATE_TRUNC('month', date_key)                     AS month_start,
        LAST_DAY(date_key)                                AS month_end,
        DAY(date_key)                                     AS day_of_month,
        DAYOFWEEK(date_key)                               AS day_of_week,       -- 0=Sun .. 6=Sat
        DAYOFYEAR(date_key)                               AS day_of_year,
        WEEKISO(date_key)                                 AS iso_week,
        YEAROFWEEKISO(date_key)                           AS iso_week_year,

        -- ── Descriptive Labels ────────────────────────────────────
        DATE_TRUNC('quarter', date_key)                   AS quarter_start,
        TO_CHAR(date_key, 'MMMM')                         AS month_name,
        TO_CHAR(date_key, 'Mon')                          AS month_short,
        TO_CHAR(date_key, 'DY')                           AS day_name_short,

        -- ── Derived: Year-Month key for trend charts ──────────────
        TO_CHAR(date_key, 'YYYY-MM')                      AS year_month,

        -- ── Derived: Fiscal year (assume FY starts July 1) ───────
        IFF(MONTH(date_key) >= 7,
            YEAR(date_key) + 1,
            YEAR(date_key)
        ) AS fiscal_year,

        IFF(MONTH(date_key) >= 7,
            MONTH(date_key) - 6,
            MONTH(date_key) + 6
        ) AS fiscal_month,

        -- ── Flags ─────────────────────────────────────────────────
        IFF(DAYOFWEEK(date_key) IN (0, 6), TRUE, FALSE)   AS is_weekend,
        IFF(date_key = LAST_DAY(date_key), TRUE, FALSE)    AS is_month_end,
        IFF(date_key = FIRST_VALUE(date_key) OVER (
            PARTITION BY DATE_TRUNC('year', date_key)
            ORDER BY date_key
        ), TRUE, FALSE)                                    AS is_year_start,

        -- ── Surrogate key ─────────────────────────────────────────
        {{ generate_surrogate_key(['date_key']) }}         AS date_key_hash

    FROM date_spine
    WHERE date_key <= '{{ var("end_date") }}'::DATE

)

SELECT * FROM dim_date
