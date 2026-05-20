$p = 'C:\Users\admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\pbir.exe'
$r = 'D:\BI_Report\Report.Report'

function pb { param([string[]]$a) & $p @a }

Write-Host "Adding KPI cards + charts to Overview..."

# KPI cards (use --no-validate because _Measures not in TMDL files seen by pbir)
pb @('add','visual','card',"$r/Overview.Page",'--title','Total Revenue Paid','-d','Values:_Measures.Total Paid','--no-validate','--x','90','--y','80','--width','390','--height','120','--name','kpi_total_paid')
pb @('add','visual','card',"$r/Overview.Page",'--title','Paid Pledges','-d','Values:_Measures.Paid Pledges','--no-validate','--x','510','--y','80','--width','390','--height','120','--name','kpi_paid_pledges')
pb @('add','visual','card',"$r/Overview.Page",'--title','Avg Gift Size','-d','Values:_Measures.Avg Gift Size','--no-validate','--x','930','--y','80','--width','390','--height','120','--name','kpi_avg_gift')
pb @('add','visual','card',"$r/Overview.Page",'--title','Pledge Conversion %','-d','Values:_Measures.Pledge Conversion %','--no-validate','--x','1350','--y','80','--width','390','--height','120','--name','kpi_conversion')

# Line chart
pb @('add','visual','lineChart',"$r/Overview.Page",'--title','Total Paid Monthly Trend','-d','Category:Dim_Date.Year Month','--no-validate','-d','Values:_Measures.Total Paid','--no-validate','-d','Values:_Measures.Total Paid PY','--no-validate','--x','90','--y','230','--width','840','--height','350','--name','trend_line_paid')

# Donuts
pb @('add','visual','donutChart',"$r/Overview.Page",'--title','Revenue by Account Type','-d','Category:Account.Account Type','-d','Values:_Measures.Total Paid','--no-validate','--x','960','--y','230','--width','370','--height','350','--name','donut_account_type')
pb @('add','visual','donutChart',"$r/Overview.Page",'--title','Revenue by Contribution Group','-d','Category:Contribution.Contribution Group','-d','Values:_Measures.Total Paid','--no-validate','--x','1360','--y','230','--width','370','--height','350','--name','donut_contrib_group')

# Bar charts (role is Y not Values for bar chart)
pb @('add','visual','clusteredBarChart',"$r/Overview.Page",'--title','Top Countries by Revenue','-d','Category:Account.Country','-d','Y:_Measures.Total Paid','--no-validate','--x','90','--y','610','--width','560','--height','255','--name','bar_top_countries')
pb @('add','visual','clusteredBarChart',"$r/Overview.Page",'--title','Revenue by Research Area','-d','Category:MRA Campaign.Research Area','-d','Y:_Measures.Total Paid','--no-validate','--x','680','--y','610','--width','560','--height','255','--name','bar_research_area')
pb @('add','visual','clusteredBarChart',"$r/Overview.Page",'--title','Revenue by Channel Focus','-d','Category:MRA Campaign.Channel Focus','-d','Y:_Measures.Total Paid','--no-validate','--x','1270','--y','610','--width','460','--height','255','--name','bar_channel_focus')

Write-Host "Overview visuals done. Validating..."
pb @('validate',"$r")
