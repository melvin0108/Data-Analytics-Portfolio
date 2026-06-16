-- ═══════════════════════════════════════════════════════════════════
-- Macro: date_spine
-- Purpose: Generate a series of dates between start_date and end_date
-- Usage:   {{ date_spine('2019-01-01', '2025-12-31') }}
-- ═══════════════════════════════════════════════════════════════════

{% macro date_spine(start_date, end_date) %}

    WITH RECURSIVE dates AS (
        SELECT {{ start_date }}::DATE AS date_value
        UNION ALL
        SELECT DATEADD('day', 1, date_value)
        FROM dates
        WHERE date_value < {{ end_date }}::DATE
    )
    SELECT date_value FROM dates

{% endmacro %}


-- ═══════════════════════════════════════════════════════════════════
-- Macro: generate_surrogate_key (overridden for Snowflake)
-- Purpose: Create an MD5 hash surrogate key from one or more columns
-- Usage:   {{ generate_surrogate_key(['col_a', 'col_b']) }}
-- ═══════════════════════════════════════════════════════════════════

{% macro generate_surrogate_key(columns) %}

    MD5(CONCAT({{ columns | join(", '|', " }}))

{% endmacro %}


-- ═══════════════════════════════════════════════════════════════════
-- Macro: ntile_score
-- Purpose: Assign NTILE quintile scores with configurable direction
-- Params:
--   column    — the column to score
--   n_tiles   — number of quantile groups (default 5)
--   direction — 'ASC' for higher=better, 'DESC' for lower=better
-- Usage: {{ ntile_score('recency_days', 5, 'DESC') }}
-- ═══════════════════════════════════════════════════════════════════

{% macro ntile_score(column, n_tiles=5, direction='ASC') %}

    NTILE({{ n_tiles }}) OVER (ORDER BY {{ column }} {{ direction }})

{% endmacro %}
