# Global variable to store the previous conversation state
Add-Type -AssemblyName System.Windows.Forms
$global:conversationState = @{
    previousQuestion = ""
    previousAnswer = ""
}
$global:theme = @"
This is a message-style chatbot that can answer questions about using Powershell. It uses a few examples to get the conversation started.
"@

function chatbot([string]$inputText) {
 
    # Check if this is a follow-up question to the previous one
    if ($inputText -eq $global:conversationState.previousQuestion) {
        Write-Output $global:conversationState.previousAnswer
        return
    }

    # Set the API endpoint and authentication headers
    $endpoint = "https://api.openai.com/v1/engines/text-davinci-003/completions"
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer YOUR_API_KEY"
    }

    # Construct the prompt based on the conversation state
    $prompt = ""
    if ($global:conversationState.previousAnswer) {
        $prompt = "$($global:conversationState.previousAnswer) "
    }
    $prompt += $inputText

    # Construct the request body
    $body = @{
        prompt = "$global:theme `n $prompt"
        max_tokens = 850
        n = 1
        temperature = 0.2
    } | ConvertTo-Json

    # Send the request and get the response
    #$response = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $body
    $chat = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $body
   
            # Get the answer from the response
            $reply = $chat.choices.text

            # Update the conversation state
            $global:conversationState.previousQuestion = $inputText
            $global:conversationState.previousAnswer = $reply
            $ReplyBox.Text = $reply
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "AI Powershell Chatbot"
$form.Width = 500
$form.Height = 420
$form.StartPosition = "CenterScreen"

$ChatLabel = New-Object System.Windows.Forms.Label
$ChatLabel.Text = "Chat with Powershell AI Assistant"
$ChatLabel.AutoSize = $true
$ChatLabel.Left = 10
$ChatLabel.Top = 10
$form.Controls.Add($ChatLabel)

$ChatBox = New-Object System.Windows.Forms.TextBox
$ChatBox.Left = 10
$ChatBox.Top = $ChatLabel.Bottom + 10
$ChatBox.Width = $form.Width - 40
$form.Controls.Add($ChatBox)

$ReplyLabel = New-Object System.Windows.Forms.Label
$ReplyLabel.Text = "Reply"
$ReplyLabel.AutoSize = $true
$ReplyLabel.Left = 10
$ReplyLabel.Top = $ChatBox.Bottom + 10
$form.Controls.Add($ReplyLabel)

$ReplyBox = New-Object System.Windows.Forms.TextBox
$ReplyBox.ReadOnly = $true
$ReplyBox.Multiline = $true  
$ReplyBox.Left = 10
$ReplyBox.Top = $ReplyLabel.Bottom + 10
$ReplyBox.Width = $form.Width - 40 
$ReplyBox.Height = 200
$form.Controls.Add($ReplyBox)

$CopyButton = New-Object System.Windows.Forms.Button
$CopyButton.Text = "Copy"
$CopyButton.Top = $ReplyBox.Bottom +40 
$CopyButton.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($ReplyBox.Text)  # Copy the contents of the ReplyBox to clipboard
    Write-Host "Copied to clipboard!"
})
$form.Controls.Add($CopyButton)

$ChatButton = New-Object System.Windows.Forms.Button
$ChatButton.Text = "Chat"
$ChatButton.Top = $ReplyBox.Bottom + 10
$ChatButton.Add_Click({
    chatbot $ChatBox.Text
})
$form.Controls.Add($ChatButton)

$form.ShowDialog() | Out-Null
