<#
.Synopsis
   Checks a document for spelling mistakes
.DESCRIPTION
   Uses the NetSpell .Net spelling library with the default dictionary that comes with it to check a given document for spelling mistakes, and can correct the mistakes in the document.
.EXAMPLE
   Invoke-SpellCheck -NetSpellDLL "C:\Modules\NetSpell.SpellChecker.dll" -DictionaryDirectory C:\Dictionary\ -Path C:\test\document.txt
#>
function Invoke-SpellCheck
{
    [CmdletBinding()]
    Param
    (
        # Enter Path to NetSpell Dll
        [Parameter(Mandatory=$false,Position=2)]
        #[ValidateScript( { $_.Exists }, "The specified file does not exist.")]
        [string]$NetSpellDLL = (Join-Path $PSScriptRoot "NetSpell.SpellChecker.dll"),
        # Dictionary Folder
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript({ Test-Path $_ -PathType 'Container' })]
        [string]$DictionaryDirectory = $PSScriptRoot,
        [Parameter(Mandatory=$true, Position=0)]
        [System.IO.FileInfo]$Path,
	[int]$Height = 500,
	[int]$Width = 700,
	[int]$fontSize = 12
    )

    Begin{
    if(!(Test-Path $DictionaryDirectory -PathType 'Container')){
    Write-Error "Directory '$DictionaryDirectory' does not exist."
    exit 1
    }
    }
    Process
    {
    Add-Type -Path "$NetSpellDLL"
    $TextBox = New-Object System.Windows.Forms.TextBox
    #$TextBox = New-Object System.Windows.Forms.RichTextBox
    $SpellChecker = New-Object NetSpell.SpellChecker.Spelling
    $SpellChecker.Dictionary.DictionaryFolder = "$DictionaryDirectory"
    $SpellChecker.add_MisspelledWord({
    param($sender, $args)
    # Show message box
$result = [System.Windows.Forms.MessageBox]::Show(
        "Misspelled word: $($_.Word)" + [Environment]::NewLine,
        "Powershell Spell Check",
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes -and $_.Suggestions -ne $null -and $_.Suggestions.Count -gt 0) {
        # Replace with the first suggestion
        $start = $TextBox.GetFirstCharIndexFromLine($_.LineIndex) + $_.TextIndex
        $length = $_.Word.Length
        $TextBox.Select($start, $length)
        $TextBox.SelectedText = $_.Suggestions[0].ToString()
        #$TextBox.SelectedText = $_.Suggestions[0]
    }
})
$SpellChecker.add_EndOfText({
    param($sender, $args)
    # Update text
    $TextBox.Text = $SpellChecker.Text
    # Show message box
    [System.Windows.Forms.MessageBox]::Show("Spell check complete.", "Spell Check", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$SpellChecker.add_DoubledWord({
    param($sender, $args)
    # Update text
    $TextBox.Text = $SpellChecker.Text
    # Show message box
    [System.Windows.Forms.MessageBox]::Show("Doubled word: $($_.Word)", "Spell Check", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
    # Create spell check window
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Spell Check"
    $Form.Size = New-Object System.Drawing.Size($Height, $Width)
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Multiline = $true
    $TextBox.ScrollBars = "Vertical"
    $TextBox.Dock = "Fill"
    $TextBox.Font = New-Object System.Drawing.Font("Arial", $fontSize)
    $TextBox.Text = get-content -Path "$Path"
    $Form.Controls.Add($TextBox)

    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = "Spell Check"
    $Button.Dock = "Bottom"
    $Button.add_Click({
        # Start Spell Checking
        $SpellChecker.Text = $TextBox.Text
        $SpellChecker.SpellCheck()
    })
    $Form.Add_Shown({
        # Set the size of the form after it is shown
        $Form.Width = $Width
        $Form.Height = $Height
    })

    $Form.Controls.Add($Button)
    # Show the form
    $Form.ShowDialog() | Out-Null
    }
    End
    {
    $Form.add_FormClosed({
    # Clean up form resources
    $Form.Dispose()
    })
    }
}