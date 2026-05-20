$p = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'
$r = 'D:\BI_Report\Report.Report'

# Final full validate with --all
Write-Host "Full validation report..."
& $p validate $r --all 2>&1
