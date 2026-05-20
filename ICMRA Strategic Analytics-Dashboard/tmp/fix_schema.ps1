Get-ChildItem 'D:\BI_Report\Report.Report\definition\pages' -Recurse -Filter 'visual.json' | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    if ($content -match '2\.8\.0') {
        $newContent = $content -replace 'visualContainer/2\.8\.0/schema\.json', 'visualContainer/2.7.0/schema.json'
        [System.IO.File]::WriteAllText($_.FullName, $newContent, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed: $($_.Name)"
    }
}

$count = (Get-ChildItem 'D:\BI_Report\Report.Report\definition\pages' -Recurse -Filter 'visual.json' | Select-String '2\.8\.0').Count
Write-Host "Remaining 2.8.0 files: $count"
