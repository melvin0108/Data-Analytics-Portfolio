$basePath = "$env:TEMP\tom_nuget\Microsoft.AnalysisServices.retail.amd64\lib\net45"
Add-Type -Path "$basePath\Microsoft.AnalysisServices.Core.dll"
Add-Type -Path "$basePath\Microsoft.AnalysisServices.Tabular.dll"
Add-Type -Path "$env:TEMP\tom_nuget\Microsoft.AnalysisServices.AdomdClient.retail.amd64\lib\net45\Microsoft.AnalysisServices.AdomdClient.dll"

$conn = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection
$conn.ConnectionString = "Data Source=localhost:58603"
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = 'EVALUATE TOPN(3, RFM, RFM[M], ASC)'

$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
        Write-Host "$($reader.GetName($i)): $($reader.GetValue($i))  " -NoNewline
    }
    Write-Host ""
}
$reader.Close()
$conn.Close()
