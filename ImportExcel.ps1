if (Test-Path C:\PowershellUniversal\Crime.xlsx){Remove-Item C:\PowershellUniversal\CrimePivot.xlsx -Force -Confirm:$false }
$ContainsBlanks = New-ConditionalText -ConditionalType ContainsBlanks
Import-Csv C:\PowershellUniversal\Crime.csv | Export-Excel C:\PowershellUniversal\Crime.xlsx
Import-Excel C:\PowershellUniversal\Crime.xlsx | Export-Excel C:\PowershellUniversal\CrimePivot.xlsx -WorksheetName Crime -TableName 'Crime' -TableStyle Medium16 -AutoNameRange -PivotRows OutCome -PivotData @{'Category'='count'} -PivotChartType PieExploded3D -Show -ConditionalText $ContainsBlanks