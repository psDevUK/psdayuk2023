function Get-NewsHeadlines {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$BBC,
        [Parameter(Mandatory=$false)]
        [switch]$CNN,
        [Parameter(Mandatory=$false)]
        [switch]$NYT,
        [Parameter(Mandatory=$false)]
        [switch]$Guardian,
        [Parameter(Mandatory=$false)]
        [switch]$NPR,
        [Parameter(Mandatory=$false)]
        [switch]$AlJazeera,
        [Parameter(Mandatory=$false)]
        [switch]$Politico
    )

    [string]$url = switch ($true) 
    {
        $BBC { 'http://feeds.bbci.co.uk/news/rss.xml' }
        $CNN { 'http://rss.cnn.com/rss/cnn_topstories.rss' }
        $NYT { 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml' }
        $Guardian { 'http://feeds.theguardian.com/theguardian/rss' }
        $NPR { 'http://www.npr.org/rss/rss.php?id=1001' }
        $AlJazeera { 'http://www.aljazeera.com/xml/rss/all.xml' }
        $Politico { 'https://www.politico.com/rss/politicopicks.xml' }
        default { 'http://feeds.bbci.co.uk/news/rss.xml' }
    }

    switch ($url)
    {
    {$_ -match "bbci.co.uk|cnn.com|aljazeera.com"} 
        {
        $rss = Invoke-RestMethod -uri $url
        [array]$data = @( 
        $rss | select @{n="Published";e={(Get-date $_.pubdate)}},
        @{N="Headline";e={($_.description."#cdata-section")}},
        @{n="View";e={$_.link}}
        )
        $data | Sort Published -desc | Out-GridView -Title "Latest BBC Headlines" -PassThru | % {Start-Process -FilePath $_.View}
        }
    {$_ -match "nytimes.com"}
        {
        $rss = Invoke-RestMethod -uri $url
        [array]$data = @( 
        $rss | select @{n="Published";e={(Get-date $_.pubdate)}},
        @{N="Headline";e={$_.description}},
        @{n="View";e={$_.link.href}}
        )
        $data | Sort Published -desc | Out-GridView -Title "Latest $url Headlines" -PassThru | % {Start-Process -FilePath $_.View}
        }
    {$_ -match "npr.org"}
        {
        $rss = Invoke-RestMethod -uri $url
        [array]$data = @( 
        $rss | select @{n="Published";e={(Get-date $_.pubdate)}},
        @{N="Headline";e={$_.description}},
        @{n="View";e={$_.link}}
        )
        $data | Sort Published -desc | Out-GridView -Title "Latest $url Headlines" -PassThru | % {Start-Process -FilePath $_.View}
        }
    {$_ -match "theguardian.com"}
        {
        $rss = Invoke-RestMethod -uri $url
        $pattern = '(?<=<p>)(?:(?!<\/p>|<a).)*<\/p>'
        $regex = [regex] $pattern
        [array]$data = @( 
        $rss | select @{n="Published";e={(Get-date $_.pubdate)}},
        @{N="Headline";e={$regex.Matches($_.description).value -replace "<strong>","" -replace "</strong>","" -replace "</p>",""}},
        @{n="View";e={$_.link}}
        )
        $data | Sort Published -desc | Out-GridView -Title "Latest $url Headlines" -PassThru | % {Start-Process -FilePath $_.View}
        }
    {$_ -match "politico.com"}
        {
        $rss = Invoke-RestMethod -uri $url
        [array]$data = @( 
        $rss | select @{n="Published";e={(Get-date ($_.pubdate -replace "EST",""))}},
        @{N="Headline";e={$_.description}},
        @{n="View";e={$_.link}}
        )
        $data | Sort Published -desc | Out-GridView -Title "Latest $url Headlines" -PassThru | % {Start-Process -FilePath $_.View}
        } 
     Default
        {
        $rss = Invoke-RestMethod -uri $url
        [array]$data = @( 
        $rss | select @{n="Published";e={(Get-date $_.pubdate)}},
        @{N="Headline";e={($_.description."#cdata-section")}},
        @{n="View";e={$_.link}}
        )
        $data | Sort Published -desc | Out-GridView -Title "Latest BBC Headlines" -PassThru | % {Start-Process -FilePath $_.View}
        }
    }
}
