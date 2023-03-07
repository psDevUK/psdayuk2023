Import-Module -Name Pode.Web
Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8090 -Protocol Http
    Use-PodeWebTemplates -Title 'Crime UK' -Theme Dark -HideSidebar
    Add-PodeWebPage -Name Crime -Icon Activity -Layouts @(
    New-PodeWebGrid -Cells @(
    New-PodeWebCell -Content @(
        New-PodeWebChart -Name 'Crime Outcome' -Type bar -ScriptBlock {
         $CSV = Import-Csv C:\PowershellUniversal\Crime.csv
         $Grouped = $CSV | group -Property Outcome | select Name,count
         $Grouped | ConvertTo-PodeWebChartData -LabelProperty Name -DatasetProperty Count
    }
    )
    New-PodeWebCell -Content @(
         New-PodeWebChart -Name 'Crime Type' -Type line -ScriptBlock {
         $CSV2 = Import-Csv C:\PowershellUniversal\Crime.csv
         $Grouped2 = $CSV2 | group -Property Category | select Name,count
         $Grouped2 | ConvertTo-PodeWebChartData -LabelProperty Name -DatasetProperty Count
    }
    )
    New-PodeWebCell -Content @(
    New-PodeWebChart -Name 'Crime Solved' -Type bar -ScriptBlock {
             $CSV3 = Import-Csv C:\PowershellUniversal\Crime.csv
         $Grouped3 = $CSV3 | group -Property Outcome | select Name,count
         $unsolvedTotal=@()
         $Grouped3 | ? {$_.Name -Match "^Investigation|^Unable|^Under" -and $_.Outcome.Length -eq 0} | Select -ExpandProperty Count | % {$unsolvedTotal += $_}
         $unsolved = ($unsolvedTotal | Measure-Object -Sum).sum
         $solved = ($CSV3.Count) - $unsolved
            @{
                Key = 'Crime' # x-axis value
                Values = @(
                    @{
                        Key = 'Solved'
                        Value = $solved # y-axis value
                    }
                    @{
                        Key = 'Unsolved'
                        Value = $unsolved # y-axis value
                    }
                )
            }
        
    }
)   
    )
        New-PodeWebTable -Name 'Crime Table' -Filter -AsCard -ScriptBlock {
    # load a csv file
    $data = Import-Csv C:\PowershellUniversal\Crime.csv
    # apply filter if present
    $filter = $WebEvent.Data.Filter
    if (![string]::IsNullOrWhiteSpace($filter)) {
        $filter = "*$($filter)*"
        $data = @($data | Where-Object { ($_.psobject.properties.value -ilike $filter).length -gt 0 })
    }
    # update table
    return $data
}
    
 )
}