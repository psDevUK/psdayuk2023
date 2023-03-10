Import-Module PowershellAI
$env:OpenAIKey = "sk-xxxxxxxxx"
function Find-Crime {
    [CmdletBinding()]
    Param
    (
       [Parameter(Mandatory = $true,
          Position = 0,
          HelpMessage = "Type the location name of interest such as Gosport or maybe a location in Gosport, like Alverstoke. Keep this to a single word"
       )]
       [Alias("Town")]
       [Alias("City")]
       [Alias("Village")]
       [string]$LocationName,
       [Parameter(Mandatory = $true)]
       [ValidateSet("2019","2020", "2021", "2022","2023")]
       [string]$Year,
       [Parameter(Mandatory = $true)]
       #[ValidateSet("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")]
       [string]$Month
    )
 
    Begin {
       Write-Verbose -Message "Obtaining the latitude and longitude of the location entered"
       $place = Invoke-RestMethod "https://geocode.maps.co/search?q={$LocationName}"
       if ($place.lat.count -gt 1) {
          $placeLat = $place.lat[0]
          $placeLon = $place.lon[0]
       }
       else {
          $placeLat = $place.lat
          $placeLon = $place.lon
       }
    }
    Process {
       try {
          $crime = Invoke-RestMethod "https://data.police.uk/api/crimes-street/all-crime?lat=$placeLat&lng=$placeLon&date=$Year-$Month" -ErrorAction Stop
                   $Props = @()
          foreach ($item in $crime){
          $Props += [PSCustomObject]@{
          Category = $item.category
          Type = $item.location_type
          Latitude = $item.location | select -ExpandProperty latitude
          Longitude = $item.location | select -ExpandProperty longitude
          Street = ($item.location).street | Select -ExpandProperty name
          Outcome = ($item.outcome_status).category
          OutcomeDate = ($item.outcome_status).date
          Reported = $item.month
          ID = $item.id
          PersistentID = $item.persistent_id
          }
          }

       }
       catch {
          Write-Warning "Crumbs something went wrong most likely an invalid location name $($_)"
       }
    }
    End {$Props.count}
 }
function Find-CrimeUK {
    [CmdletBinding()]
    Param
    (
       [Parameter(Mandatory = $true,
          Position = 0,
          HelpMessage = "Type the location name of interest such as Gosport or maybe a location in Gosport, like Alverstoke. Keep this to a single word"
       )]
       [Alias("Town")]
       [Alias("City")]
       [Alias("Village")]
       [string]$LocationName,
       [Parameter(Mandatory = $true)]
       [ValidateSet("2019", "2020", "2021", "2022","2023")]
       [string]$Year,
       [Parameter(Mandatory = $true)]
       [ValidateSet("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")]
       [string]$Month
    )
 
    Begin {
       Write-Verbose -Message "Obtaining the latitude and longitude of the location entered"
       $place = Invoke-RestMethod "https://geocode.maps.co/search?q={$LocationName}"
       if ($place.lat.count -gt 1) {
          $placeLat = $place.lat[0]
          $placeLon = $place.lon[0]
       }
       else {
          $placeLat = $place.lat
          $placeLon = $place.lon
       }
    }
    Process {
       try {
          $crime = Invoke-RestMethod "https://data.police.uk/api/crimes-street/all-crime?lat=$placeLat&lng=$placeLon&date=$Year-$Month" -ErrorAction Stop
                   $Props = @()
          foreach ($item in $crime){
          $Props += [PSCustomObject]@{
          Category = $item.category
          Type = $item.location_type
          Latitude = $item.location | select -ExpandProperty latitude
          Longitude = $item.location | select -ExpandProperty longitude
          Street = ($item.location).street | Select -ExpandProperty name
          Outcome = ($item.outcome_status).category
          OutcomeDate = ($item.outcome_status).date
          Reported = $item.month
          ID = $item.id
          PersistentID = $item.persistent_id
          }
          }
       }
       catch {
          Write-Warning "Crumbs something went wrong most likely an invalid location name $($_)"
       }
    }
    End {
        $Props | Export-Csv /PowershellUniversal/Crime.csv -notypeinformation
       Write-Verbose -Message "Script Finished $(Get-Date)"
    }
 }
$Navigation = @(
    New-UDListItem -Label 'Home' -Icon (New-UDIcon -Icon Home) -OnClick {
        Invoke-UDRedirect -Url '/Home'
    }
    New-UDListItem -Label 'Statistics' -Icon (New-UDIcon -Icon ChartBar) -OnClick {
        Invoke-UDRedirect -Url '/Statistics'
    }
    New-UDListItem -Label 'Map' -Icon (New-UDIcon -Icon MapPin) -OnClick {
        Invoke-UDRedirect -Url '/Map'
    }
)
$HomePage = New-UDPage -Name 'Home' -Content {
    New-UDTypography -Text "Find Crime" -FontWeight 600 -Variant 'h4'
New-UDRow -Columns {
New-UDColumn -Id 'col1' -Content {
    $(New-UDDateTime -InputObject (Get-Date) -Format 'DD/MM/YYYY')
    New-UDUnDraw -Name 'security'
    } -SmallSize 2 -MediumSize 2 -LargeSize 2
 New-UDColumn -Content {
New-UDTypography -Text "Search Here" -Variant 'h5'
New-UDTextbox -Id 'txtLocation' -Label 'Enter Location' -Icon (New-UDIcon -Icon 'Map') -Autofocus -Placeholder 'Type a name of a city or town'
New-UDParagraph -Content {} 
New-UDDatePicker -Id 'datePicker' -Label 'Select Month and Year' -MaximumDate (Get-Date) -Format 'MM yyyy' -OnChange {
    Show-UDToast -Message $body -MessageColor 'green' -Duration 5000
} 
New-UDParagraph -Content {}

New-UDButton -Text "Find Crime" -Icon (New-UDIcon -Icon 'DoorOpen') -Color Primary -OnClick {
    $Cache:psLocation = (Get-UDElement -Id 'txtLocation').value
    $psMonth = [string](Get-UDElement -Id 'datePicker').value.ToString('MM') 
    $Cache:psYear = [string](Get-UDElement -Id 'datePicker').value.ToString('yyyy')
    Show-UDToast -Message "Seaching the location $($Cache:psLocation) for the $psMonth month and in the year $($Cache:psYear)" -Duration 10000
    Find-CrimeUK -LocationName "$($Cache:psLocation)" -Year $($Cache:psYear) -Month $($psMonth)
}
} -SmallSize 2 -MediumSize 2 -LargeSize 2

New-UDColumn -Content {
New-UDDynamic -AutoRefresh -AutoRefreshInterval 30 -Content {
    $ai = ai "Crime in $($Cache:psLocation) UK"
    New-UDCard -Content {
        New-UDTypography -Variant h5 -Text "$($Cache:psLocation) Crime"
        New-UDTypography -Text "$ai"
    }
}
}-SmallSize 5 -MediumSize 5 -LargeSize 5

New-UDColumn -Content {
  New-UDDynamic -AutoRefresh -AutoRefreshInterval 30 -Content {  
 $ai = ai "Population $($Cache:psLocation) UK $($Cache:psYear)"
    New-UDCard -Content {
        New-UDTypography -Variant h5 -Text "Population"
        New-UDTypography -Text "$ai"
    }
  }
} -SmallSize 3 -MediumSize 3 -LargeSize 3
New-UDColumn -Content {
    New-UDDynamic -AutoRefresh -AutoRefreshInterval 20 -Content {
$CSV = Import-Csv /PowershellUniversal/Crime.csv
$Coloumns = @(
    New-UDTableColumn -Property Type -Title Type
    New-UDTableColumn -Property Category -Title Category
    New-UDTableColumn -Property Street -Title Street
    New-UDTableColumn -Property Reported -Title Reported
    New-UDTableColumn -Property Outcome -Title Outcome
)
New-UDTable -Id 'CrimeTable' -Title "Crime Reported In $($Cache:psLocation)" -Icon (New-UDIcon -Icon 'Table') -Data $CSV -ShowFilter -ShowExport -ShowPagination -ShowSearch -PageSize 15 -ShowSort -ShowRefresh -Columns $Coloumns
    }
} -SmallSize 9 -MediumSize 9 -LargeSize 9
New-UDColumn -Content {
New-UDunDraw -Name 'file-searching'
New-UDunDraw -Name 'code-typing'
New-UDunDraw -Name 'filing-system'
New-UDunDraw -Name 'programming'
} -SmallSize 3 -MediumSize 3 -LargeSize 3
    }
}

$Statistics = New-UDPage -Name 'Statistics' -Content {
New-UDTypography -Text "Crime Statistics Outcomes for $($Cache:psLocation)" -FontWeight 600 -Variant 'h4'
New-UDRow -Columns {
    New-UDColumn -Content {
    New-UDDynamic -AutoRefresh -AutoRefreshInterval 20 -Content {
    $CSV2 = Import-Csv /PowershellUniversal/Crime.csv
    $Grouped = $CSV2 | Group-Object -Property Outcome | sort Count -Descending | Select Name,Count
    New-UDChartJS -Type 'bar' -Data $Grouped -DataProperty Count -LabelProperty Name -Options @{
        indexAxis = "y"
        plugins = @{
            legend = @{
                position = "top"
            }
        }
    }
    }
    } -SmallSize 12 -MediumSize 6 -LargeSize 6
    
    New-UDColumn -SmallSize 12 -MediumSize 6 -LargeSize 3 -Content {
        New-UDDynamic -AutoRefresh -AutoRefreshInterval 20 -Content {
            $gdata = Import-Csv /PowershellUniversal/Crime.csv
            $value = $gdata | ? {$_.Outcome.Length -gt 2 -and $_.Outcome -notmatch "no suspect identified|Unable|Under"}
            $gTotal = $gdata.count
            New-UDTypography -Variant h5 -Text "Crimes Solved in $($Cache:psLocation)"
            New-UDGauge -value $value.count -MaxValue $gTotal
            New-UDTypography -Variant h3 -Text "$($value.count)" -FontWeight 700 -Style @{
                "padding-left" = "150px"
            }
        }
    }
    New-UDColumn -Content {
    New-UDunDraw -Name 'data-report'
    } -SmallSize 3 -MediumSize 3 -LargeSize 3
    New-UDColumn -SmallSize 12 -MediumSize 6 -LargeSize 3 -Content {
        New-UDDynamic -AutoRefresh -AutoRefreshInterval 20 -Content {
       $pieD = Import-Csv /PowershellUniversal/Crime.csv
       $pieG = $pieD | Group-Object -Property Category | Select Name,Count
        $MultiArray = @()
        $MultiArray += , @('Type', 'Total' )
        foreach ($obj in $pieG){
            $MultiArray += , @("$($obj.Name)",$($obj.Count))
        }
       
        new-udpiechart3d -Id "PIECHART" -Title "Type Of Crime" -data @($MultiArray)       
        }
    }
    New-UDColumn -Content {
    New-UDDynamic -AutoRefreshInterval 60 -Content {
New-UDParagraph -Content {}        
New-UDTypography -Variant h4 -Text "$($Cache:psLocation) Crime Breakdown $($Cache:psYear)" -Style @{
     "padding-left" = "180px"
     "display" = "Grid"
}
New-UDTypography -Text "Below is a heatmap showing a report of each month throughout the year, and reporting on the total crime recorded for that month. As these statistics are only on a monthly basis I can only produce one figure for the total month." -Style @{
     "padding-left" = "180px"
     "display" = "Grid"
}
$months = @("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")
$Data = @()
 $Year = $Cache:psYear
 $CURRENTDATE= GET-DATE -Year $Year -Month $months[1] -Hour 0 -Minute 0 -Second 0
 $MonthAgo = $CURRENTDATE.AddMonths(-1)
 $FIRSTDAYOFMONTH=GET-DATE $MonthAgo -Day 1
$months | Foreach-Object -begin {
 $Data += @{
        day = ($FIRSTDAYOFMONTH).ToString("yyyy-MM-dd")
        value = (Find-Crime -LocationName "$($Cache:psLocation)" -Year $($Cache:psYear) -Month 01)
    }
 } -Process{ $Data += @{
        day = ($FIRSTDAYOFMONTH).AddMonths($_ * 1).ToString("yyyy-MM-dd")
        value = (Find-Crime -LocationName "$($Cache:psLocation)" -Year $($Cache:psYear) -Month $_)
    } } -End{
        $Cache:CalData = $Data
    }


$From = $FIRSTDAYOFMONTH
$To = $FIRSTDAYOFMONTH.AddMonths(11)
New-UDNivoChart -Calendar -Data $Data -From $From -To $To -Height 100 -Width 650 -MarginTop 10 -MarginRight 10 -MarginBottom 5 -MarginLeft 165

New-UDElement -Tag 'h4' -Attributes @{
                        style = @{
                            "padding-left" = '200px'
                        }
                    } -Content {
                        New-UDNumber -Start $(($Cache:CalData.value | Measure-Object -sum).Sum / 2) -End $(($Cache:CalData.value | Measure-Object -sum).Sum) -Delay 2 -Prefix "This equates to" -PostFix "crimes committed"
                    }
    }
} -SmallSize 12 -MediumSize 6 -LargeSize 6
New-UDColumn -Content {
        New-UDunDraw -Name 'data-trends'
    } -SmallSize 6 -MediumSize 6 -LargeSize 3 
New-UDColumn -Content {
 $DataLine = $Cache:CalData 
 New-UDChartJS -Type 'line' -Data $DataLine -DataProperty value -LabelProperty day
} -SmallSize 12 -MediumSize 6 -LargeSize 6
New-UDColumn -Content {
New-UDDynamic -Content {
$ai2 = ai "worst crime to have ever happened in $($Cache:psLocation) uk"
New-UDTypography -Variant h4 -Text "Worst Crime Reported"
New-UDTypography -Text "$ai2"

} -AutoRefresh -AutoRefreshInterval 30
} -SmallSize 12 -MediumSize 6 -LargeSize 3
New-UDColumn -Content {New-UDunDraw -Name 'news'} -SmallSize 3 -MediumSize 3 -LargeSize 3
New-UDColumn -SmallSize 10 -MediumSize 10 -LargeSize 10 -Content {
        New-UDDynamic -AutoRefresh -AutoRefreshInterval 50 -Content {
            $PData = Import-Csv /PowershellUniversal/Crime.csv
            $hash = @()
                foreach ($item in $PData) {
                    $hash += @{
                        Category = $item.Category
                        Type = $item.Type
                        Street = $item.Steet
                        Outcome = $item.Outcome
                        Reported = $item.Reported
                    }
                }
                New-UDPivotTable -Data { $hash }
       }
    }
    New-UDColumn -Content {New-UDunDraw -Name 'data'} -SmallSize 2 -MediumSize 2 -LargeSize 2

} #End Row
} #End Page



$Map = New-UDPage -Name 'Map' -Content {
    New-UDTypography -Text "Crime Map Statistics for $($Cache:psLocation)" -FontWeight 600 -Variant 'h4'
New-UDRow -Columns {
    New-UDColumn -Content {
    $CSV3 = Import-Csv /PowershellUniversal/Crime.csv
    New-UDDynamic -Content {
New-UDMap -Endpoint {
    New-UDMapRasterLayer -TileServer 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
     for ($i = 1; $i -lt $($CSV3.count); $i++)
 { 
  New-UDMapMarker -Latitude "$($CSV3.Latitude[$i])" -Longitude "$($CSV3.Longitude[$i])"   
 }
} -Latitude $($CSV3.Latitude[0]) -Longitude $($CSV3.Longitude[0]) -Zoom 14 -Height '100vh'
} -AutoRefresh -AutoRefreshInterval 60

    } -SmallSize 9 -MediumSize 9 -LargeSize 9
    New-UDColumn -Content {
        New-UDDynamic -AutoRefresh -AutoRefreshInterval 30 -Content {
        $words = Import-Csv /PowershellUniversal/Crime.csv | Select -ExpandProperty Category
        [System.Collections.ArrayList]$UDWordTreeData = @()
              #foreach file content and add to list
              $words | % {
                  $UDWordTreeData.Add(@([string]$_)) | Out-Null
              }
              New-UDWordTree -Id "WORDTREE"-width "100%" -height "325px" -data { $UDWordTreeData } -word $Session:filter
        }
        
    } -SmallSize 3 -MediumSize 3 -LargeSize 3
}
}

New-UDDashboard -Title 'Crime UK' -Pages @(
    $HomePage
    $Statistics
    $Map
) -Navigation $Navigation #-Stylesheets /PowershellUniversal/style.css