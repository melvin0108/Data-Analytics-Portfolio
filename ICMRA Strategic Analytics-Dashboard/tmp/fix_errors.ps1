$p = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'
$r = 'D:\BI_Report\Report.Report'

# Fix Market Basket page bindings to use correct BasketPairs column names
# matrix_basket: Rows=Antecedent, Columns=Consequent, Values=Pair Support
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -c Rows 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -c Columns 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Rows:BasketPairs.Antecedent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Columns:BasketPairs.Consequent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Values:_Measures.Pair Support' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Values:_Measures.Pair Confidence' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/matrix_basket.Visual" -a 'Values:_Measures.Pair Lift' -t Measure --no-validate 2>&1

# bar_lift_top10: Category=Antecedent, Y=Pair Lift
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -c Category 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -c Y 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -a 'Category:BasketPairs.Antecedent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/bar_lift_top10.Visual" -a 'Y:_Measures.Pair Lift' -t Measure --no-validate 2>&1

# tbl_basket_detail: Antecedent, Consequent, Support, Confidence, Lift
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -c Values 2>&1 | Out-Null
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:BasketPairs.Antecedent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:BasketPairs.Consequent' -t Column --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:_Measures.Pair Support' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:_Measures.Pair Confidence' -t Measure --no-validate 2>&1
& $p visuals bind "$r/market_basket_07.Page/tbl_basket_detail.Visual" -a 'Values:_Measures.Pair Lift' -t Measure --no-validate 2>&1

Write-Host "Market Basket bindings done."
& $p validate $r 2>&1 | Select-Object -Last 3
