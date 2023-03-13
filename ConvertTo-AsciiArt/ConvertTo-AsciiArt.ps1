Function ConvertTo-AsciiArt {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ImagePath,
        [Parameter(Mandatory=$false)]
        [int]$Width = 80,
        [Parameter(Mandatory=$false)]
        [int]$Height = 160
    )

    # Load the System.Drawing namespace
    Add-Type -AssemblyName System.Drawing

    # Load the image file
    $image = [System.Drawing.Image]::FromFile($ImagePath)

    # Set the width and height of the ASCII art
    $width = $Width
    $height = $Height

    # Resize the image to fit the console
    $aspectRatio = $image.Width / $image.Height
    $newWidth = $height * $aspectRatio
    $newHeight = $width / $aspectRatio
    if ($newWidth -gt $width) {
        $consoleWidth = $width
        $consoleHeight = $newHeight
    } else {
        $consoleWidth = $newWidth
        $consoleHeight = $height
    }
    $image = $image.GetThumbnailImage($consoleWidth, $consoleHeight, $null, [IntPtr]::Zero)

    # Convert the image to ASCII art
    $ascii = ""
    for ($y = 0; $y -lt $image.Height; $y++) {
        for ($x = 0; $x -lt $image.Width; $x++) {
            $pixel = [System.Drawing.Color]$image.GetPixel($x, $y)
            $brightness = ($pixel.R + $pixel.G + $pixel.B) / 3
            if ($brightness -ge 230) {
                $ascii += " "
            } elseif ($brightness -ge 200) {
                $ascii += "."
            } elseif ($brightness -ge 180) {
                $ascii += ":"
            } elseif ($brightness -ge 160) {
                $ascii += "-"
            } elseif ($brightness -ge 130) {
                $ascii += "="
            } elseif ($brightness -ge 100) {
                $ascii += "+"
            } elseif ($brightness -ge 70) {
                $ascii += "*"
            } elseif ($brightness -ge 50) {
                $ascii += "#"
            } elseif ($brightness -ge 30) {
                $ascii += "%"
            } else {
                $ascii += "@"
            }
        }
        $ascii += "`n"
    }

    # Output the ASCII art to the console
    Write-Host $ascii
}
