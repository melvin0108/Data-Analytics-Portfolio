$p = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'
$r = 'D:\BI_Report\Report.Report'

function bm { param($v,$role,$field) & $p visuals bind ($r+'/'+$v) -a ($role+':'+$field) -t Measure --no-validate 2>&1 | ForEach-Object { if ($_ -match 'Error') { Write-Host "  ERR: $_" } } }
function bc { param($v,$role,$field) & $p visuals bind ($r+'/'+$v) -a ($role+':'+$field) -t Column --no-validate 2>&1 | ForEach-Object { if ($_ -match 'Error') { Write-Host "  ERR: $_" } } }

Write-Host '=== Binding Overview ==='

# Cards (measures)
bm 'Overview.Page/kpi_total_paid.Visual' 'Values' '_Measures.Total Paid'
bm 'Overview.Page/kpi_paid_pledges.Visual' 'Values' '_Measures.Paid Pledges'
bm 'Overview.Page/kpi_avg_gift.Visual' 'Values' '_Measures.Avg Gift Size'
bm 'Overview.Page/kpi_conversion.Visual' 'Values' '_Measures.Pledge Conversion %'

# Line chart: Category=Column, Y=Measure
bc 'Overview.Page/trend_line_paid.Visual' 'Category' 'Dim_Date.Year Month'
bm 'Overview.Page/trend_line_paid.Visual' 'Y' '_Measures.Total Paid'
bm 'Overview.Page/trend_line_paid.Visual' 'Y' '_Measures.Total Paid PY'

# Donuts
bc 'Overview.Page/donut_account_type.Visual' 'Category' 'Account.Account Type'
bm 'Overview.Page/donut_account_type.Visual' 'Values' '_Measures.Total Paid'
bc 'Overview.Page/donut_contrib_group.Visual' 'Category' 'Contribution.Contribution Group'
bm 'Overview.Page/donut_contrib_group.Visual' 'Values' '_Measures.Total Paid'

# Bars
bc 'Overview.Page/bar_top_countries.Visual' 'Category' 'Account.Country'
bm 'Overview.Page/bar_top_countries.Visual' 'Y' '_Measures.Total Paid'
bc 'Overview.Page/bar_research_area.Visual' 'Category' 'MRA Campaign.Research Area'
bm 'Overview.Page/bar_research_area.Visual' 'Y' '_Measures.Total Paid'
bc 'Overview.Page/bar_channel_focus.Visual' 'Category' 'MRA Campaign.Channel Focus'
bm 'Overview.Page/bar_channel_focus.Visual' 'Y' '_Measures.Total Paid'

Write-Host 'Done. Validate:'
& $p validate $r 2>&1 | Select-Object -Last 4
