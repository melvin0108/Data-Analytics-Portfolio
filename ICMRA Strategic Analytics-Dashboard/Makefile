.PHONY: help snowflake-setup snowflake-teardown dbt-debug dbt-build dbt-test dbt-docs dbt-run-staging dbt-run-marts clean

# ─────────────────────────────────────────────────────────────
# ICMRA Analytics Platform — Makefile
# ─────────────────────────────────────────────────────────────

SNOWSQL      ?= snowsql
DBT          ?= dbt
SNOWFLAKE_ACCT ?= your_account

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

# ── Snowflake Infrastructure ───────────────────────────────

snowflake-setup: ## Create database, schemas, raw tables, warehouse (run in order)
	@echo "==> Creating Snowflake infrastructure..."
	$(SNOWSQL) -f snowflake/01_create_database.sql
	$(SNOWSQL) -f snowflake/02_create_raw_tables.sql
	$(SNOWSQL) -f snowflake/04_create_warehouse.sql
	@echo "==> Snowflake infrastructure ready."

snowflake-load: ## Load Excel source data into RAW schema
	$(SNOWSQL) -f snowflake/03_load_data.sql

snowflake-teardown: ## Drop the entire ICMRA database (destructive!)
	@echo "WARNING: This will drop database ICMRA_DB and all data."
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] || exit 1
	$(SNOWSQL) -q "DROP DATABASE IF EXISTS ICMRA_DB;"

# ── dbt Commands ────────────────────────────────────────────

dbt-debug: ## Verify dbt can connect to Snowflake
	cd dbt_project && $(DBT) debug

dbt-deps: ## Install dbt packages
	cd dbt_project && $(DBT) deps

dbt-build: ## Full build: run + test all models
	cd dbt_project && $(DBT) build

dbt-run-staging: ## Build staging layer only
	cd dbt_project && $(DBT) run --select staging

dbt-run-intermediate: ## Build intermediate layer only
	cd dbt_project && $(DBT) run --select intermediate

dbt-run-marts: ## Build mart layer only
	cd dbt_project && $(DBT) run --select marts

dbt-run-reporting: ## Build reporting layer only
	cd dbt_project && $(DBT) run --select reporting

dbt-test: ## Run all schema + custom tests
	cd dbt_project && $(DBT) test

dbt-snapshot: ## Capture SCD Type 2 snapshots
	cd dbt_project && $(DBT) snapshot

dbt-docs: ## Generate and serve dbt documentation site
	cd dbt_project && $(DBT) docs generate && $(DBT) docs serve

dbt-lineage: ## Show model dependency graph
	cd dbt_project && $(DBT) ls --select +marts.* --output graph

# ── Full Pipeline ───────────────────────────────────────────

pipeline: dbt-deps dbt-build dbt-snapshot dbt-docs ## Run full ELT pipeline
	@echo "==> Pipeline complete. Docs served at http://localhost:8080"

# ── Cleanup ─────────────────────────────────────────────────

clean: ## Remove dbt build artifacts
	rm -rf dbt_project/target/
	rm -rf dbt_project/logs/
	rm -rf dbt_project/dbt_packages/
	@echo "==> Cleaned dbt artifacts."
