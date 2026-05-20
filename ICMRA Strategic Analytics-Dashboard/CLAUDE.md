# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Business Intelligence & Data Analytics** university assignment (Swinburne University) for a fictional client: **ICMRA** (International Consortium for Medical Research Advancement). The goal is to produce a **Strategic Analytics & Visualisation Report** (~2,500 words) and an **Executive Infographic** based on fundraising data from 2019–2025.

**Tooling:** Microsoft Power BI Desktop 2.153.910.0 64-bit (April 2026), `.pbip` project format.

## Deliverables

| Deliverable | Spec |
| :--- | :--- |
| Report | ~2,500 words (excludes exec summary, TOC, references, appendices), 12pt, 1.5 spacing, APA references, numbered pages |
| Technical File | `.pbix` or `.xlsx` with all Power Query Applied Steps visible |
| Executive Infographic | One-page board-level visual summary |

---

## Dataset: `ICMRA Dataset 2019-2025.xlsx`

Four relational tables sourced from the Excel file at `D:\BI_Report\ICMRA Dataset 2019-2025.xlsx`:

| Table | Role | Key Fields |
| :--- | :--- | :--- |
| **Medical Research Grant Appeal** | Fact table (pledge transactions) | `Pledge ID`, `Account ID`, `Campaign ID`, `Cont Type ID`, `Referral Source`, `Appeal Close Date`, `Payment Date`, `Pledge-Pay Amount` |
| **MRA Campaign** | Campaign dimension | `Campaign Code`, `Campaign Name`, `Research Area`, `Campaign Type`, `Appeal Category`, `Priority Level`, `Target Amount`, `Campaign Budget`, `Channel Focus`, `Campaign Start Date`, `Campaign End Date` |
| **Contribution** | Lookup/dimension | `Contribution_ID`, `Contribution Type`, `Contribution Group` |
| **Account** | Contributor dimension | `Account Code`, `Account Name`, `Contact Person`, `Account Type`, `Country`, `Region`, `Account Segment`, `Preferred Referral Source`, `Funding Capacity Band`, `Account Since`, `Organisation Size Band` |

---

## Semantic Model — Scope of Responsibility

> **CRITICAL RULE — Who changes what:**

| Change Type | Who Does It | How |
|---|---|---|
| Power Query transformations inside the 4 existing source tables | **User manually** in Power BI Desktop | Open Power Query Editor → edit M steps |
| Everything else (DAX measures, calculated columns/tables, parameter tables, relationships, table/column properties, hiding fields, format strings) | **Claude via Power BI MCP** | Use the MCP tools |

Claude must **never** ask the user to hand-edit `.tmdl` files directly. All semantic layer changes must go through the Power BI MCP.

---

## File Structure

```
D:\BI_Report\
├── ICMRA Dataset 2019-2025.xlsx          -- source data (never modify)
├── Report.pbip                           -- Power BI project entry point
├── Report.Report/                        -- report layout (pages, visuals)
│   └── definition/pages/                -- one folder per report page
├── Report.SemanticModel/                 -- semantic model (TMDL format)
│   └── definition/
│       ├── model.tmdl
│       ├── relationships.tmdl
│       ├── tables/                       -- one .tmdl per table
│       └── cultures/en-US.tmdl
├── PowerBIskill.md                       -- master DAX/layout reference guide
├── Initial_Data_Dictionary.md            -- field definitions
├── Task_Description.md                   -- full assignment brief
├── semantic_model_reference.md           -- CURRENT model state (tables, measures, relationships)
├── visual_field_reference.md             -- CURRENT report pages & visual field bindings
└── theme.json                            -- custom visual theme
```

**Do not manually edit files under `Report.SemanticModel/`** — use the Power BI MCP instead.

---

## Current Semantic Model State

> **Canonical reference:** `semantic_model_reference.md` (generated 2026-04-28, validated live).  
> Summary below; see that file for full DAX expressions.

### Tables (19 total)

| Table | Type | Notes |
|---|---|---|
| `Medical Research Grant Appeal` | Source (fact) | 8 source + 6 calculated columns |
| `Account` | Source (dimension) | 11 source + `Churn Flag` calculated column |
| `MRA Campaign` | Source (dimension) | 11 source columns |
| `Contribution` | Source (dimension) | 3 source columns |
| `Dim_Date` | Calculated | 2019–2025, marked as date table on `Date` column |
| `RFM` | Calculated | Per-account R/F/M summary with quintile scores |
| `Dim_RankRFM` | Calculated | 125-row segment lookup; 11 segments |
| `BasketPairs` | Calculated | Market basket co-occurrence pairs |
| `_Measures` | Calculated (placeholder) | All 114 measures live here |
| `Growth Rate Param` | Parameter | –20% to +50%, step 1% |
| `Goal Target Param` | Parameter | $0–$100M, step $1M |
| `Top N Param` | Parameter | 5–50, step 5 |
| `Select Measure` | Parameter | Metric toggle: Total Paid / Total Pledged / Paid Pledges |
| `LocalDateTable_*` (×5) | System (hidden) | Auto date/time (legacy) |

### Calculated Columns in Fact Table

| Column | DAX Summary |
|---|---|
| `Payment Status` | `IF(ISBLANK([Payment Date]), "Pledged-Unpaid", "Paid")` |
| `First Payment Date` | Earliest payment date per Account ID |
| `First Payment Month` | First day of `First Payment Date` month (Cohort row key) |
| `Payment Month` | First day of `Payment Date` month |
| `Month Offset` | `DATEDIFF(First Payment Month, Payment Month, MONTH)` (Cohort column key) |
| `Days to Pay` | `DATEDIFF(Appeal Close Date, Payment Date, DAY)` |

### Relationships

| From | From Column | To | To Column | Active | Filter |
|---|---|---|---|---|---|
| Medical Research Grant Appeal | `Payment Date` | Dim_Date | `Date` | ✅ | → |
| Medical Research Grant Appeal | `Appeal Close Date` | Dim_Date | `Date` | ❌ | → |
| Medical Research Grant Appeal | `Account ID` | Account | `Account Code` | ✅ | → |
| Medical Research Grant Appeal | `Campaign ID` | MRA Campaign | `Campaign Code` | ✅ | → |
| Medical Research Grant Appeal | `Cont Type ID` | Contribution | `Contribution_ID` | ✅ | → |
| MRA Campaign | `Campaign Start Date` | Dim_Date | `Date` | ❌ | → |
| RFM | `Account ID` | Account | `Account Code` | ✅ | **↔** |
| RFM | `RFM Score` | Dim_RankRFM | `Scores` | ✅ | **↔** |

> Inactive relationships (Appeal Close Date, Campaign Start Date) are activated in DAX via `USERELATIONSHIP`. Bidirectional filter on RFM → Account and RFM → Dim_RankRFM enables segment slicing to propagate back to the fact table.

### Measures (`_Measures` table — 114 total, all in Ready state)

Three-layer pattern — see `semantic_model_reference.md` for full DAX:

- **Layer 1 — Base:** `Total Pledged`, `Total Paid`, `Paid Pledges`, `Total Pledges`, `Total Contributors`, `Avg Gift Size`, `Pledge Conversion %`, `Avg Days to Pay`, `Total Campaign Budget`, `Total Target`, `Target Achievement %`, `ROI`
- **Layer 2 — Time Intel:** `[Metric] PY / PM / PQ`, `[Metric] YoY/MoM/QoQ Growth %` (for Total Paid, Total Pledged, Total Contributors, Avg Gift Size, Pledge Conversion %, Revenue per Contributor)
- **Layer 3 — Display:** `[Metric] Growth KPI` (▲/▼ strings), `[Metric] Trend Color`, `Line Bar Color`, `Sparkline Marker Color`, dynamic title measures
- **CLV & Churn:** `Purchase Frequency`, `Contributor Lifetime (m)`, `Customer Lifetime Value`, `Revenue per Contributor`, `Churn Rate`
- **Cohort:** `Cohort Size`, `Retention Rate`
- **RFM:** `Avg Recency`, `Avg Frequency`, `Avg Monetary`
- **Market Basket:** `Pair Support`, `Pair Confidence`, `Pair Lift`
- **What-If / Goal Seek:** `Growth Rate Selected`, `Goal Target Selected`, `Projected Paid`, `Gap to Goal`, `Goal Status Color`
- **Metric Toggle:** `Selected Measure Value`

---

## Report Pages (10 pages, 69 visuals)

> **Canonical reference:** `visual_field_reference.md` (generated 2026-04-23, zero field errors).

| # | Page | Key Visuals |
|---|---|---|
| 1 | Overview | 4 KPI cards, monthly trend line, 2 donuts, 3 bar charts, year slicer |
| 2 | Tooltip (hidden 320×240) | Reserved hidden tooltip page |
| 3 | Contributor Insight | Column, bar, scatter, contributor detail table |
| 4 | Campaign Performance | ROI column, combo pledge/paid, gauge, campaign detail table |
| 5 | RFM Analysis | 4 KPI cards, treemap, bar, scatter, RFM detail table |
| 6 | CLV & Churn | 4 KPI cards, donut, bar, line, CLV detail table |
| 7 | Cohort Retention | Cohort matrix (`First Payment Month` × `Month Offset` → `Retention Rate`) |
| 8 | Market Basket | Association rules matrix, top 10 lift bar, basket detail table |
| 9 | What-If / Goal Seek | 3 KPI cards, 2 slicers (growth rate, goal target), line, waterfall, scenario table |
| 10 | Advanced / Anomalies | Scatter, 2 bar/column, anomaly detail table |

### Known Manual Fixes Required After Each Save in PBI Desktop

Power BI Desktop reverts certain field bindings on Ctrl+S — these must be fixed manually:

- **Market Basket `bar_lift_top10`:** Y-axis must use `BasketPairs.Antecedent` (not `Contribution.Contribution Group`). Also add Top N filter: Top 10 by `Pair Lift`.
- **Market Basket `matrix_basket`:** Rows = `BasketPairs.Antecedent`, Columns = `BasketPairs.Consequent`.
- **Cohort `matrix_cohort`:** Rows = `Medical Research Grant Appeal.First Payment Month`, Columns = `Month Offset`, Values = `Retention Rate`.
- **What-If slicers:** `slicer_growth_rate` → `Growth Rate Param.Growth Rate`; `slicer_goal_target` → `Goal Target Param.Goal Target`.

---

## Power Query Rules

- All data cleaning **must** use Power Query — standard Excel functions are not permitted.
- All Applied Steps must remain visible/reproducible.
- Changes to Power Query M code inside the 4 source tables must be made **by the user** in Power BI Desktop.

---

## Power BI Dashboard Ground Rules

### Layout Convention — Canvas 1440×900 or 1800×900

- **Left vertical panel (x:0–75):** page navigation buttons + slicers/filters
- **Header strip (x:66–canvas width, y:0–68):** dark `#1E1E2F` bar
- **KPI row:** Card visuals immediately below the header strip
- **Remaining right canvas:** all other charts

### Required Techniques

| Technique | Rule |
|---|---|
| **DAX UDF layers** | Layer 1 = base; Layer 2 = time-intel (PY/YoY/MoM/QoQ); Layer 3 = KPI string / color. Higher layers call lower ones — never hardcode logic in display measures. |
| **Parameters** | `GENERATESERIES` for numeric sliders; `DATATABLE` for field parameters. |
| **Bookmarks** | Each page has bookmark-linked toggle buttons + a "Reset Filters" bookmark button. |
| **Custom Tooltips** | Hidden pages (320×240, `HiddenInViewMode`, `type: Tooltip`) for scatter/map hover. |
| **Conditional Formatting** | Always via **"Field value" → color measure** — never manual color scales. |

### Measures vs Calculated Columns

- **Calculated column:** used as axis/legend/slicer/matrix header, or needs per-row storage (e.g., RFM scores, CohortMonth, Payment Status)
- **Measure:** any aggregation responding to filter context; drives conditional formatting colors; used as value/size/tooltip field

### All Measures Table

All DAX measures must live in **`_Measures`** (the single dedicated placeholder table). Never scatter measures across fact or dimension tables.

### DAX Naming Conventions

- Base: `Total Amount`, `Total Contributors`, `Paid Pledges`
- Prior period: `[Metric] PY`, `[Metric] PM`, `[Metric] PQ`
- Growth: `[Metric] YoY Growth %`, `[Metric] MoM Growth %`, `[Metric] QoQ Growth %`
- KPI string: `[Metric] Growth KPI` → `"▲ 12.3% YoY"` / `"▼ 5.6% YoY"`
- Color measures: `[Metric] Trend Color`, `Line Bar Color`
- Dynamic titles: `<Visual Noun> Title`

### Color Reference

| Color | Hex | Usage |
|---|---|---|
| Positive / Good | `#38b64b` | Growth positive, max bar, goal met |
| Negative / Bad | `#ee1c25` | Growth negative, min bar, goal not met, churn |
| ICMRA Blue (accent) | `#2E86DE` | Default bar/line color |
| Container / Nav | `#10314D` | Left nav strip, header strip |
| Page Background | `#081C2E` | Dark page canvas |

---

## Reference Documents

- **`semantic_model_reference.md`** — authoritative current state: all tables, columns, measures (with DAX), relationships, and parameter tables.
- **`visual_field_reference.md`** — authoritative current state: all 10 report pages, visual names, types, and exact field bindings. Includes manual fix guide for visuals that revert after save.
- **`PowerBIskill.md`** — comprehensive DAX patterns, layout coordinates, theme colors, visual-by-visual specifications. Consult before building any DAX measure or designing a page layout.
- **`Initial_Data_Dictionary.md`** — field-level definitions for all four source tables.
- **`Task_Description.md`** — full assignment brief and marking criteria.
- **`theme.json`** — custom dark-purple theme applied to the report.
- **`ICMRA_Analytics_Report.md`** — the written strategic analytics report (~2,500 words body), ready for formatting into Word/PDF for submission.
