$CSV = Import-Csv C:\PowershellUniversal\Crime.csv
$unsolved = $CSV | ? Outcome -EQ 'Investigation complete; no suspect identified'
$unable = $CSV | ? Outcome -EQ 'Unable to prosecute suspect'
$investigating = $CSV | ? Outcome -EQ 'Under investigation'
$Court = $CSV | ? Outcome -EQ 'Awaiting court outcome'
$Further = $CSV | ? Outcome -EQ 'Further investigation is not in the public interest'
$localRes = $CSV | ? Outcome -EQ 'Local resolution'
$caution = $CSV | ? Outcome -EQ 'Offender given a caution'
$noInfo = $CSV | ? {$_.Outcome.Length -lt 1}
Dashboard -Name 'Charts - Bar' -FilePath C:\PowershellUniversal\CrimeUK.html {
    Section -Invisible {
        Panel {
            Chart {
                ChartLegend -Name 'Unsolved','Unable to solve'
                ChartBar -Name 'Total Crimes' -Value $CSV.Count
                ChartBar -Name 'Unsolved' -Value $($unsolved.count)
                ChartBar -Name 'Unable to prosecute' -Value $($unable.count)
            }
        }
        Panel {
            Chart {
                ChartToolbar -Download
                ChartLegend -Name 'unknown','Unsolved','Unable','Investigating','Court','Further','Resolution','Caution'
                ChartBar -Name 'Test' -Value $($noInfo.Count),$($unsolved.count), $($unable.count),$($investigating.Count),$($Court.count),$($Further.count),$($localRes.count),$($caution.count)
            }
        }
    }
Section -Invisible {
        Table -DataTable $CSV -HideFooter {
            TableConditionalFormatting -Name 'Outcome' -ComparisonType string -Operator lt -Value 1 -Color White -BackgroundColor black -Row
            TableConditionalFormatting -Name 'Outcome' -ComparisonType string -Operator eq -Value 'Investigation complete; no suspect identified' -Color White -BackgroundColor Crimson -Row
            TableConditionalFormatting -Name 'Outcome' -ComparisonType string -Operator eq -Value 'Unable to prosecute suspect' -Color White -BackgroundColor Orange -Row
            TableConditionalFormatting -Name 'Outcome' -ComparisonType string -Operator eq -Value 'Local resolution' -Color White -BackgroundColor Green -Row
            TableConditionalFormatting -Name 'Outcome' -ComparisonType string -Operator eq -Value 'Offender given a caution' -Color White -BackgroundColor Green -Row
        }
    }
    } -Show