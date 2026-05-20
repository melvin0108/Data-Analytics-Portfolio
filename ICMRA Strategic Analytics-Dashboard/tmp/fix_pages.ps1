$schema = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json'
$pbir = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'

$pages = @(
    @{id='contributor_insight_02'; name='Contributor Insight'},
    @{id='campaign_performance_03'; name='Campaign Performance'},
    @{id='rfm_analysis_04'; name='RFM Analysis'},
    @{id='clv_churn_05'; name='CLV and Churn'},
    @{id='cohort_retention_06'; name='Cohort Retention'},
    @{id='market_basket_07'; name='Market Basket'},
    @{id='whatif_goalseek_08'; name='What-If Goal Seek'},
    @{id='advanced_anomalies_09'; name='Advanced Anomalies'}
)

foreach ($p in $pages) {
    $path = "D:\BI_Report\Report.Report\definition\pages\$($p.id)\page.json"
    $content = @"
{
  "`$schema": "$schema",
  "name": "$($p.id)",
  "displayName": "$($p.name)",
  "displayOption": "FitToPage",
  "height": 900,
  "width": 1800
}
"@
    [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Fixed: $($p.name)"
}

Write-Host "Running validate..."
& $pbir validate 'D:\BI_Report\Report.Report' 2>&1
