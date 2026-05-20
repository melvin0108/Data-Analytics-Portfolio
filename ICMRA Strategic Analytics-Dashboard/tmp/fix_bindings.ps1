$p = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'
$r = 'D:\BI_Report\Report.Report'

Write-Host "=== Fix Cohort Retention Matrix ===" -ForegroundColor Cyan
& $p visuals bind "$r/cohort_retention_06.Page/matrix_cohort.Visual" -c Rows 2>&1 | Out-Null
& $p visuals bind "$r/cohort_retention_06.Page/matrix_cohort.Visual" -c Columns 2>&1 | Out-Null
& $p visuals bind "$r/cohort_retention_06.Page/matrix_cohort.Visual" -c Values 2>&1 | Out-Null
& $p visuals bind "$r/cohort_retention_06.Page/matrix_cohort.Visual" -a 'Rows:Medical Research Grant Appeal.First Payment Month' -t Column --no-validate 2>&1
& $p visuals bind "$r/cohort_retention_06.Page/matrix_cohort.Visual" -a 'Columns:Medical Research Grant Appeal.Month Offset' -t Column --no-validate 2>&1
& $p visuals bind "$r/cohort_retention_06.Page/matrix_cohort.Visual" -a 'Values:_Measures.Retention Rate' -t Measure --no-validate 2>&1
Write-Host "Cohort done."

Write-Host "=== Fix What-If Slicers ===" -ForegroundColor Cyan
& $p visuals bind "$r/whatif_goalseek_08.Page/slicer_growth_rate.Visual" -c Values 2>&1 | Out-Null
& $p visuals bind "$r/whatif_goalseek_08.Page/slicer_growth_rate.Visual" -a 'Values:Growth Rate Param.Growth Rate' -t Column --no-validate 2>&1
& $p visuals bind "$r/whatif_goalseek_08.Page/slicer_goal_target.Visual" -c Values 2>&1 | Out-Null
& $p visuals bind "$r/whatif_goalseek_08.Page/slicer_goal_target.Visual" -a 'Values:Goal Target Param.Goal Target' -t Column --no-validate 2>&1
Write-Host "What-If slicers done."

Write-Host "=== Fix Market Basket bindings ===" -ForegroundColor Cyan
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -c Rows 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -c Columns 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -c Values 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Rows:BasketPairs.Antecedent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Columns:BasketPairs.Consequent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Values:_Measures.Pair Support' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Values:_Measures.Pair Confidence' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Values:_Measures.Pair Lift' -t Measure --no-validate 2>&1

& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -c Category 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -c Y 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -a 'Category:BasketPairs.Antecedent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -a 'Y:_Measures.Pair Lift' -t Measure --no-validate 2>&1

& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -c Values 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:BasketPairs.Antecedent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:BasketPairs.Consequent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:_Measures.Pair Support' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:_Measures.Pair Confidence' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:_Measures.Pair Lift' -t Measure --no-validate 2>&1
Write-Host "Market Basket done."

Write-Host "=== Final validation ===" -ForegroundColor Cyan
& $p validate $r --fields 2>&1 | Select-Object -Last 25
