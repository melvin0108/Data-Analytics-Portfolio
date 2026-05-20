$pagesDir = "D:\BI_Report\Report.Report\definition\pages"
$schema = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json"

function CreatePage($id, $displayName, $w, $h, $hidden, $tooltip) {
    $dir = "$pagesDir\$id"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    New-Item -ItemType Directory -Path "$dir\visuals" -Force | Out-Null

    $obj = [ordered]@{}
    $obj["`$schema"] = $schema
    $obj["name"] = $id
    $obj["displayName"] = $displayName
    $obj["displayOption"] = "FitToPage"
    $obj["height"] = $h
    $obj["width"] = $w
    if ($hidden) { $obj["visibility"] = "HiddenInViewMode" }
    if ($tooltip) { $obj["type"] = "Tooltip" }

    $obj | ConvertTo-Json -Depth 5 | Set-Content "$dir\page.json" -Encoding UTF8
    Write-Host "Created: $displayName"
}

CreatePage "tooltip_page_01" "Tooltip" 320 240 $true $true
CreatePage "contributor_insight_02" "Contributor Insight" 1800 900 $false $false
CreatePage "campaign_performance_03" "Campaign Performance" 1800 900 $false $false
CreatePage "rfm_analysis_04" "RFM Analysis" 1800 900 $false $false
CreatePage "clv_churn_05" "CLV and Churn" 1800 900 $false $false
CreatePage "cohort_retention_06" "Cohort Retention" 1800 900 $false $false
CreatePage "market_basket_07" "Market Basket" 1800 900 $false $false
CreatePage "whatif_goalseek_08" "What-If Goal Seek" 1800 900 $false $false
CreatePage "advanced_anomalies_09" "Advanced Anomalies" 1800 900 $false $false

# Update pages.json
$pageOrder = @(
    "37bdcea38ca92b40603d",
    "tooltip_page_01",
    "contributor_insight_02",
    "campaign_performance_03",
    "rfm_analysis_04",
    "clv_churn_05",
    "cohort_retention_06",
    "market_basket_07",
    "whatif_goalseek_08",
    "advanced_anomalies_09"
)
$pagesJson = [ordered]@{}
$pagesJson["`$schema"] = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.0.0/schema.json"
$pagesJson["pageOrder"] = $pageOrder
$pagesJson["activePageName"] = "37bdcea38ca92b40603d"

$pagesJson | ConvertTo-Json -Depth 3 | Set-Content "$pagesDir\pages.json" -Encoding UTF8
Write-Host "Updated pages.json with 10 pages"
