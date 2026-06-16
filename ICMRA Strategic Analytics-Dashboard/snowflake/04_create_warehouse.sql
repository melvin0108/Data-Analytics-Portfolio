-- ═══════════════════════════════════════════════════════════════════
-- ICMRA Analytics — Virtual Warehouse Configuration
-- Run as ACCOUNTADMIN
-- ═══════════════════════════════════════════════════════════════════

-- ── ETL Warehouse (dbt builds) ────────────────────────────────────

CREATE OR REPLACE WAREHOUSE ICMRA_ETL_WH
    WAREHOUSE_SIZE = XSMALL
    AUTO_SUSPEND = 120          -- seconds of inactivity before auto-suspend
    AUTO_RESUME  = TRUE         -- auto-resume when queries arrive
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1       -- single cluster for this dataset size
    SCALING_POLICY = STANDARD
    COMMENT = 'dbt transformation warehouse — X-Small for ICMRA dataset (< 100K rows)';

-- ── BI Warehouse (Power BI queries) ───────────────────────────────

CREATE OR REPLACE WAREHOUSE ICMRA_BI_WH
    WAREHOUSE_SIZE = XSMALL
    AUTO_SUSPEND = 60           -- faster suspend (BI is bursty)
    AUTO_RESUME  = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2       -- allow multi-cluster for concurrent dashboard users
    SCALING_POLICY = ECONOMY
    ENABLE_QUERY_ACCELERATION = TRUE   -- speed up large table scans
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 4
    COMMENT = 'Power BI query warehouse — auto-scales for concurrent dashboard access';

-- ── Grant warehouse access to roles ───────────────────────────────

GRANT USAGE ON WAREHOUSE ICMRA_ETL_WH TO ROLE ICMRA_ETL_ROLE;
GRANT USAGE ON WAREHOUSE ICMRA_BI_WH  TO ROLE ICMRA_BI_ROLE;
GRANT USAGE ON WAREHOUSE ICMRA_BI_WH  TO ROLE ICMRA_ANALYST_ROLE;
GRANT OPERATE ON WAREHOUSE ICMRA_ETL_WH TO ROLE ICMRA_ETL_ROLE;
GRANT OPERATE ON WAREHOUSE ICMRA_BI_WH  TO ROLE ICMRA_BI_ROLE;

-- ── Resource Monitors (cost control) ──────────────────────────────

CREATE OR REPLACE RESOURCE MONITOR ICMRA_COST_MONITOR
    CREDIT_QUOTA = 50           -- 50 Snowflake credits per month
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND_IMMEDIATE
    COMMENT = 'Monthly credit budget alert — notifies at 80%, suspends at 100%';

ALTER WAREHOUSE ICMRA_ETL_WH SET RESOURCE_MONITOR = ICMRA_COST_MONITOR;
ALTER WAREHOUSE ICMRA_BI_WH  SET RESOURCE_MONITOR = ICMRA_COST_MONITOR;
