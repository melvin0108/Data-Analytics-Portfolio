$p = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'
$r = 'D:\BI_Report\Report.Report'

function bm { param($v,$role,$field) & $p visuals bind ($r+'/'+$v) -a ($role+':'+$field) -t Measure --no-validate 2>&1 | ForEach-Object { if ($_ -match 'Error') { Write-Host "  ERR[$v]: $_" } } }
function bc { param($v,$role,$field) & $p visuals bind ($r+'/'+$v) -a ($role+':'+$field) -t Column --no-validate 2>&1 | ForEach-Object { if ($_ -match 'Error') { Write-Host "  ERR[$v]: $_" } } }

function add_visuals_from_json {
    param($page_id, $json_str)
    $f = "D:\BI_Report\tmp\visuals_tmp.json"
    [System.IO.File]::WriteAllText($f, $json_str, (New-Object System.Text.UTF8Encoding $false))
    & $p add visual "$r/$page_id.Page" --from-json $f 2>&1 | Select-String "Created|Error" | ForEach-Object { Write-Host "  $_" }
}

# ====== CONTRIBUTOR INSIGHT ======
Write-Host '=== Contributor Insight ==='
add_visuals_from_json 'contributor_insight_02' @'
[
  {"visual_type": "clusteredColumnChart", "name": "col_paid_by_seg_yr", "x": 90, "y": 80, "width": 700, "height": 380, "title": "Revenue by Account Segment & Year"},
  {"visual_type": "clusteredBarChart", "name": "bar_capacity_type", "x": 820, "y": 80, "width": 500, "height": 380, "title": "Revenue by Funding Capacity"},
  {"visual_type": "scatterChart", "name": "scatter_capacity_gift", "x": 1350, "y": 80, "width": 420, "height": 380, "title": "Capacity vs Avg Gift"},
  {"visual_type": "tableEx", "name": "tbl_contributor_detail", "x": 90, "y": 490, "width": 1680, "height": 380, "title": "Contributor Detail"}
]
'@

bm 'contributor_insight_02.Page/col_paid_by_seg_yr.Visual' 'Y' '_Measures.Total Paid'
bc 'contributor_insight_02.Page/col_paid_by_seg_yr.Visual' 'Category' 'Account.Account Segment'
bc 'contributor_insight_02.Page/col_paid_by_seg_yr.Visual' 'Legend' 'Dim_Date.Year'
bm 'contributor_insight_02.Page/bar_capacity_type.Visual' 'Y' '_Measures.Total Paid'
bc 'contributor_insight_02.Page/bar_capacity_type.Visual' 'Category' 'Account.Funding Capacity Band'
bc 'contributor_insight_02.Page/bar_capacity_type.Visual' 'Legend' 'Account.Account Type'
bc 'contributor_insight_02.Page/scatter_capacity_gift.Visual' 'Category' 'Account.Account Name'
bm 'contributor_insight_02.Page/scatter_capacity_gift.Visual' 'X' '_Measures.Total Paid'
bm 'contributor_insight_02.Page/scatter_capacity_gift.Visual' 'Y' '_Measures.Avg Gift Size'
bc 'contributor_insight_02.Page/scatter_capacity_gift.Visual' 'Legend' 'Account.Region'
bc 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' 'Account.Account Name'
bc 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' 'Account.Account Type'
bc 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' 'Account.Account Segment'
bc 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' 'Account.Country'
bm 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' '_Measures.Total Paid'
bm 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' '_Measures.Paid Pledges'
bm 'contributor_insight_02.Page/tbl_contributor_detail.Visual' 'Values' '_Measures.Avg Gift Size'

# ====== CAMPAIGN PERFORMANCE ======
Write-Host '=== Campaign Performance ==='
add_visuals_from_json 'campaign_performance_03' @'
[
  {"visual_type": "clusteredColumnChart", "name": "col_roi_research", "x": 90, "y": 80, "width": 620, "height": 360, "title": "ROI by Research Area"},
  {"visual_type": "gauge", "name": "gauge_target", "x": 740, "y": 80, "width": 320, "height": 360, "title": "Target Achievement"},
  {"visual_type": "lineClusteredColumnComboChart", "name": "combo_pledge_paid", "x": 1090, "y": 80, "width": 680, "height": 360, "title": "Pledge Volume vs Paid Revenue"},
  {"visual_type": "tableEx", "name": "tbl_campaign_detail", "x": 90, "y": 470, "width": 1680, "height": 400, "title": "Campaign Performance Detail"}
]
'@

bc 'campaign_performance_03.Page/col_roi_research.Visual' 'Category' 'MRA Campaign.Research Area'
bm 'campaign_performance_03.Page/col_roi_research.Visual' 'Y' '_Measures.ROI'
bm 'campaign_performance_03.Page/gauge_target.Visual' 'Values' '_Measures.Target Achievement %'
bm 'campaign_performance_03.Page/gauge_target.Visual' 'MaxValue' '_Measures.Total Target'
bc 'campaign_performance_03.Page/combo_pledge_paid.Visual' 'Category' 'Dim_Date.Year Month'
bm 'campaign_performance_03.Page/combo_pledge_paid.Visual' 'Y' '_Measures.Total Pledges'
bm 'campaign_performance_03.Page/combo_pledge_paid.Visual' 'ColumnY' '_Measures.Total Paid'
bc 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' 'MRA Campaign.Campaign Name'
bc 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' 'MRA Campaign.Research Area'
bc 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' 'MRA Campaign.Channel Focus'
bm 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' '_Measures.Total Paid'
bm 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' '_Measures.Target Achievement %'
bm 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' '_Measures.ROI'
bm 'campaign_performance_03.Page/tbl_campaign_detail.Visual' 'Values' '_Measures.Total Campaign Budget'

# ====== RFM ANALYSIS ======
Write-Host '=== RFM Analysis ==='
add_visuals_from_json 'rfm_analysis_04' @'
[
  {"visual_type": "card", "name": "kpi_rfm_contributors", "x": 90, "y": 80, "width": 280, "height": 120, "title": "Total Contributors"},
  {"visual_type": "card", "name": "kpi_rfm_avg_r", "x": 400, "y": 80, "width": 280, "height": 120, "title": "Avg Recency (Days)"},
  {"visual_type": "card", "name": "kpi_rfm_avg_f", "x": 710, "y": 80, "width": 280, "height": 120, "title": "Avg Frequency"},
  {"visual_type": "card", "name": "kpi_rfm_avg_m", "x": 1020, "y": 80, "width": 280, "height": 120, "title": "Avg Monetary Value"},
  {"visual_type": "treemap", "name": "treemap_rfm_seg", "x": 90, "y": 230, "width": 600, "height": 400, "title": "Contributors by RFM Segment"},
  {"visual_type": "clusteredBarChart", "name": "bar_rfm_seg_paid", "x": 720, "y": 230, "width": 500, "height": 400, "title": "Revenue by RFM Segment"},
  {"visual_type": "tableEx", "name": "tbl_rfm_detail", "x": 1250, "y": 230, "width": 520, "height": 400, "title": "RFM Segment Detail"},
  {"visual_type": "scatterChart", "name": "scatter_rfm_fm", "x": 90, "y": 660, "width": 800, "height": 210, "title": "Frequency vs Monetary by Segment"}
]
'@

bm 'rfm_analysis_04.Page/kpi_rfm_contributors.Visual' 'Values' '_Measures.Total Contributors'
bm 'rfm_analysis_04.Page/kpi_rfm_avg_r.Visual' 'Values' '_Measures.Avg Recency Days'
bm 'rfm_analysis_04.Page/kpi_rfm_avg_f.Visual' 'Values' '_Measures.Avg Frequency'
bm 'rfm_analysis_04.Page/kpi_rfm_avg_m.Visual' 'Values' '_Measures.Avg Monetary'
bc 'rfm_analysis_04.Page/treemap_rfm_seg.Visual' 'Category' 'Dim_RankRFM.Segment'
bm 'rfm_analysis_04.Page/treemap_rfm_seg.Visual' 'Values' '_Measures.Total Contributors'
bc 'rfm_analysis_04.Page/bar_rfm_seg_paid.Visual' 'Category' 'Dim_RankRFM.Segment'
bm 'rfm_analysis_04.Page/bar_rfm_seg_paid.Visual' 'Y' '_Measures.Total Paid'
bc 'rfm_analysis_04.Page/tbl_rfm_detail.Visual' 'Values' 'Dim_RankRFM.Segment'
bm 'rfm_analysis_04.Page/tbl_rfm_detail.Visual' 'Values' '_Measures.Total Contributors'
bm 'rfm_analysis_04.Page/tbl_rfm_detail.Visual' 'Values' '_Measures.Total Paid'
bm 'rfm_analysis_04.Page/tbl_rfm_detail.Visual' 'Values' '_Measures.Avg Gift Size'
bc 'rfm_analysis_04.Page/scatter_rfm_fm.Visual' 'Category' 'Dim_RankRFM.Segment'
bm 'rfm_analysis_04.Page/scatter_rfm_fm.Visual' 'X' '_Measures.Avg Frequency'
bm 'rfm_analysis_04.Page/scatter_rfm_fm.Visual' 'Y' '_Measures.Avg Monetary'
bm 'rfm_analysis_04.Page/scatter_rfm_fm.Visual' 'Size' '_Measures.Total Paid'

# ====== CLV & CHURN ======
Write-Host '=== CLV & Churn ==='
add_visuals_from_json 'clv_churn_05' @'
[
  {"visual_type": "card", "name": "kpi_avg_gift_clv", "x": 90, "y": 80, "width": 380, "height": 120, "title": "Avg Gift Size"},
  {"visual_type": "card", "name": "kpi_purchase_freq", "x": 500, "y": 80, "width": 380, "height": 120, "title": "Purchase Frequency"},
  {"visual_type": "card", "name": "kpi_clv", "x": 910, "y": 80, "width": 380, "height": 120, "title": "Customer Lifetime Value"},
  {"visual_type": "card", "name": "kpi_churn_rate", "x": 1320, "y": 80, "width": 380, "height": 120, "title": "Churn Rate"},
  {"visual_type": "donutChart", "name": "donut_clv_seg", "x": 90, "y": 230, "width": 420, "height": 380, "title": "CLV by RFM Segment"},
  {"visual_type": "lineChart", "name": "line_rev_per_contrib", "x": 540, "y": 230, "width": 700, "height": 380, "title": "Revenue per Contributor over Time"},
  {"visual_type": "tableEx", "name": "tbl_clv_detail", "x": 1270, "y": 230, "width": 500, "height": 380, "title": "CLV Contributor Detail"},
  {"visual_type": "clusteredBarChart", "name": "bar_churn_segment", "x": 90, "y": 640, "width": 700, "height": 230, "title": "Churn Risk by Segment"}
]
'@

bm 'clv_churn_05.Page/kpi_avg_gift_clv.Visual' 'Values' '_Measures.Avg Gift Size'
bm 'clv_churn_05.Page/kpi_purchase_freq.Visual' 'Values' '_Measures.Purchase Frequency'
bm 'clv_churn_05.Page/kpi_clv.Visual' 'Values' '_Measures.Customer Lifetime Value'
bm 'clv_churn_05.Page/kpi_churn_rate.Visual' 'Values' '_Measures.Churn Rate'
bc 'clv_churn_05.Page/donut_clv_seg.Visual' 'Category' 'Dim_RankRFM.Segment'
bm 'clv_churn_05.Page/donut_clv_seg.Visual' 'Values' '_Measures.Customer Lifetime Value'
bc 'clv_churn_05.Page/line_rev_per_contrib.Visual' 'Category' 'Dim_Date.Year Month'
bm 'clv_churn_05.Page/line_rev_per_contrib.Visual' 'Y' '_Measures.Revenue per Contributor'
bc 'clv_churn_05.Page/tbl_clv_detail.Visual' 'Values' 'Account.Account Name'
bc 'clv_churn_05.Page/tbl_clv_detail.Visual' 'Values' 'Account.Account Type'
bm 'clv_churn_05.Page/tbl_clv_detail.Visual' 'Values' '_Measures.Customer Lifetime Value'
bm 'clv_churn_05.Page/tbl_clv_detail.Visual' 'Values' '_Measures.Total Paid'
bc 'clv_churn_05.Page/bar_churn_segment.Visual' 'Category' 'Dim_RankRFM.Segment'
bm 'clv_churn_05.Page/bar_churn_segment.Visual' 'Y' '_Measures.Churn Rate'

# ====== COHORT RETENTION ======
Write-Host '=== Cohort Retention ==='
add_visuals_from_json 'cohort_retention_06' @'
[
  {"visual_type": "matrix", "name": "matrix_cohort", "x": 90, "y": 80, "width": 1680, "height": 790, "title": "Cohort Retention Matrix (First Payment Month vs Months Since)"}
]
'@

bc 'cohort_retention_06.Page/matrix_cohort.Visual' 'Rows' 'Medical Research Grant Appeal.FirstPaymentMonth'
bc 'cohort_retention_06.Page/matrix_cohort.Visual' 'Columns' 'Medical Research Grant Appeal.MonthOffset'
bm 'cohort_retention_06.Page/matrix_cohort.Visual' 'Values' '_Measures.Retention Rate'

# ====== MARKET BASKET ======
Write-Host '=== Market Basket ==='
add_visuals_from_json 'market_basket_07' @'
[
  {"visual_type": "matrix", "name": "matrix_basket", "x": 90, "y": 80, "width": 800, "height": 400, "title": "Association Rules: Support & Confidence"},
  {"visual_type": "clusteredBarChart", "name": "bar_lift_top10", "x": 920, "y": 80, "width": 850, "height": 400, "title": "Top 10 Rules by Lift"},
  {"visual_type": "tableEx", "name": "tbl_basket_detail", "x": 90, "y": 510, "width": 1680, "height": 360, "title": "Basket Pairs Detail"}
]
'@

bc 'market_basket_07.Page/matrix_basket.Visual' 'Rows' 'BasketPairs.Account ID'
bc 'market_basket_07.Page/matrix_basket.Visual' 'Columns' 'BasketPairs.Contribution Group'
bm 'market_basket_07.Page/matrix_basket.Visual' 'Values' '_Measures.Pair Support'
bc 'market_basket_07.Page/bar_lift_top10.Visual' 'Category' 'BasketPairs.Contribution Group'
bm 'market_basket_07.Page/bar_lift_top10.Visual' 'Y' '_Measures.Pair Lift'
bc 'market_basket_07.Page/tbl_basket_detail.Visual' 'Values' 'BasketPairs.Account ID'
bc 'market_basket_07.Page/tbl_basket_detail.Visual' 'Values' 'BasketPairs.Contribution Group'
bm 'market_basket_07.Page/tbl_basket_detail.Visual' 'Values' '_Measures.Pair Support'
bm 'market_basket_07.Page/tbl_basket_detail.Visual' 'Values' '_Measures.Pair Lift'

# ====== WHAT-IF / GOAL SEEK ======
Write-Host '=== What-If / Goal Seek ==='
add_visuals_from_json 'whatif_goalseek_08' @'
[
  {"visual_type": "slicer", "name": "slicer_growth_rate", "x": 90, "y": 80, "width": 380, "height": 120, "title": "Growth Rate (%)"},
  {"visual_type": "slicer", "name": "slicer_goal_target", "x": 500, "y": 80, "width": 380, "height": 120, "title": "Goal Target ($)"},
  {"visual_type": "card", "name": "kpi_total_paid_wi", "x": 920, "y": 80, "width": 240, "height": 120, "title": "Current Paid"},
  {"visual_type": "card", "name": "kpi_projected_paid", "x": 1180, "y": 80, "width": 240, "height": 120, "title": "Projected Paid"},
  {"visual_type": "card", "name": "kpi_gap_to_goal", "x": 1440, "y": 80, "width": 280, "height": 120, "title": "Gap to Goal"},
  {"visual_type": "lineChart", "name": "line_historical_trend", "x": 90, "y": 230, "width": 900, "height": 380, "title": "Historical Paid Revenue Trend"},
  {"visual_type": "waterfallChart", "name": "waterfall_scenario", "x": 1020, "y": 230, "width": 750, "height": 380, "title": "Scenario: Base vs Projected vs Target"},
  {"visual_type": "tableEx", "name": "tbl_scenario_by_year", "x": 90, "y": 640, "width": 1680, "height": 230, "title": "Year-by-Year Scenario Comparison"}
]
'@

bc 'whatif_goalseek_08.Page/slicer_growth_rate.Visual' 'Field' 'Growth Rate Param.Value'
bc 'whatif_goalseek_08.Page/slicer_goal_target.Visual' 'Field' 'Goal Target Param.Value'
bm 'whatif_goalseek_08.Page/kpi_total_paid_wi.Visual' 'Values' '_Measures.Total Paid'
bm 'whatif_goalseek_08.Page/kpi_projected_paid.Visual' 'Values' '_Measures.Projected Paid'
bm 'whatif_goalseek_08.Page/kpi_gap_to_goal.Visual' 'Values' '_Measures.Gap to Goal'
bc 'whatif_goalseek_08.Page/line_historical_trend.Visual' 'Category' 'Dim_Date.Year'
bm 'whatif_goalseek_08.Page/line_historical_trend.Visual' 'Y' '_Measures.Total Paid'
bm 'whatif_goalseek_08.Page/line_historical_trend.Visual' 'Y' '_Measures.Projected Paid'
bc 'whatif_goalseek_08.Page/waterfall_scenario.Visual' 'Category' 'Dim_Date.Year'
bm 'whatif_goalseek_08.Page/waterfall_scenario.Visual' 'Y' '_Measures.Total Paid'
bc 'whatif_goalseek_08.Page/tbl_scenario_by_year.Visual' 'Values' 'Dim_Date.Year'
bm 'whatif_goalseek_08.Page/tbl_scenario_by_year.Visual' 'Values' '_Measures.Total Paid'
bm 'whatif_goalseek_08.Page/tbl_scenario_by_year.Visual' 'Values' '_Measures.Projected Paid'
bm 'whatif_goalseek_08.Page/tbl_scenario_by_year.Visual' 'Values' '_Measures.Gap to Goal'

# ====== ADVANCED / ANOMALIES ======
Write-Host '=== Advanced / Anomalies ==='
add_visuals_from_json 'advanced_anomalies_09' @'
[
  {"visual_type": "clusteredColumnChart", "name": "col_pledge_vs_paid_channel", "x": 90, "y": 80, "width": 700, "height": 380, "title": "Pledge vs Paid by Channel Focus"},
  {"visual_type": "clusteredBarChart", "name": "bar_anomaly_segment", "x": 820, "y": 80, "width": 700, "height": 380, "title": "Avg Gift Size by Account Segment"},
  {"visual_type": "scatterChart", "name": "scatter_pledge_paid_dist", "x": 1550, "y": 80, "width": 220, "height": 380, "title": "Gift Distribution"},
  {"visual_type": "tableEx", "name": "tbl_anomaly_detail", "x": 90, "y": 490, "width": 1680, "height": 380, "title": "Outlier Detail — High-Value Pledges"}
]
'@

bc 'advanced_anomalies_09.Page/col_pledge_vs_paid_channel.Visual' 'Category' 'MRA Campaign.Channel Focus'
bm 'advanced_anomalies_09.Page/col_pledge_vs_paid_channel.Visual' 'Y' '_Measures.Total Pledged'
bm 'advanced_anomalies_09.Page/col_pledge_vs_paid_channel.Visual' 'Y' '_Measures.Total Paid'
bc 'advanced_anomalies_09.Page/bar_anomaly_segment.Visual' 'Category' 'Account.Account Segment'
bm 'advanced_anomalies_09.Page/bar_anomaly_segment.Visual' 'Y' '_Measures.Avg Gift Size'
bc 'advanced_anomalies_09.Page/scatter_pledge_paid_dist.Visual' 'Category' 'Account.Account Name'
bm 'advanced_anomalies_09.Page/scatter_pledge_paid_dist.Visual' 'X' '_Measures.Total Pledged'
bm 'advanced_anomalies_09.Page/scatter_pledge_paid_dist.Visual' 'Y' '_Measures.Total Paid'
bc 'advanced_anomalies_09.Page/tbl_anomaly_detail.Visual' 'Values' 'Account.Account Name'
bc 'advanced_anomalies_09.Page/tbl_anomaly_detail.Visual' 'Values' 'Account.Account Type'
bm 'advanced_anomalies_09.Page/tbl_anomaly_detail.Visual' 'Values' '_Measures.Total Paid'
bm 'advanced_anomalies_09.Page/tbl_anomaly_detail.Visual' 'Values' '_Measures.Avg Gift Size'
bm 'advanced_anomalies_09.Page/tbl_anomaly_detail.Visual' 'Values' '_Measures.Avg Days to Pay'

Write-Host '=== All pages done. Final validate ==='
& $p validate $r 2>&1 | Select-Object -Last 6
