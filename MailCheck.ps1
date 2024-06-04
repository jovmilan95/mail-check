param (
    [Parameter(Mandatory = $true)]
    [string]$SenderPassword,
    [Parameter(Mandatory = $true)]
    [string]$ReciverPassword,
    [string]$SenderAccount  = 'monitoring@tmail.trezor.gov.rs',
    [string]$SmtpServer     = 'tmail.trezor.gov.rs',
    [int]   $SmtpPort       = 25,
    [string]$ReciverAccount = 'tmailping@knowit.rs',
    [string]$ImapServer     = 'imap.knowit.rs',
    [int]   $ImapPort       = 993,
    [int]   $MaxAttempts    = 10,
    [int]   $DelaySeconds   = 3
)
$ErrorActionPreference = 'Stop'
$TranscriptPath = "log\$(Get-Date -Format 'yyyy-MM-dd').log"
Start-Transcript -Path $TranscriptPath -Append -NoClobber

function Invoke-Retry {
    param (
        [scriptblock]$ScriptBlock,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 10
    )

    $attempt = 0
    $success = $false

    while ($attempt -lt $MaxAttempts -and -not $success) {
        try {
            $attempt++
            Write-Output "Attempt $attempt..."
            & $ScriptBlock

            $success = $true
            Write-Output "The method executed successfully on attempt $attempt."
        } catch {
            Write-Output "Error: $_"

            if ($attempt -lt $MaxAttempts) {
                Write-Output "Waiting $DelaySeconds seconds before the next attempt..."
                Start-Sleep -Seconds $DelaySeconds
            } else {
                Write-Output "All attempts failed."
            }
        }
    }

    if (-not $success) {
        throw "RetryLimitExceeded: The method failed after $MaxAttempts attempts."
    }
}

function Confirm-EmailDelivery {
    param (
        [string]$Server,
        [int]   $Port,
        [string]$Username,
        [string]$Password,
        [string]$SearchFrom,
        [string]$SearchSubject
    )
    Import-Module Mailozaurr

    $Client = Connect-IMAP -Server $Server -Password $Password -UserName $Username -Port $Port -Options Auto
    $output = Get-IMAPFolder -FolderAccess ReadWrite -Client $Client
    $searchCriteria = "SUBJECT '$SearchSubject' FROM '$SearchFrom'"
    $inbox = $Client.Data.Inbox.Search($searchCriteria)
    if ($inbox.UniqueIds.Count -eq 0) {
        throw "No emails were found matching the search criteria $($searchCriteria)."
    }
    Write-Host "Found $($inbox.UniqueIds.Count) emails matching the search criteria $($searchCriteria)."
    foreach ($id in $inbox.UniqueIds) {
        $message = $Client.data.Inbox.GetMessage($id)
        $moveToFolder = $Client.data.GetFolder('Trash')
        $Client.Data.Inbox.MoveTo($id, $moveToFolder)
        Write-Host "Email '$($message.subject)' has been moved to the trash folder."
    }
}

try {
    Get-ChildItem $PSScriptRoot\inc\*.ps1 | % { . $_ }

    $securePassword = ConvertTo-SecureString $SenderPassword -AsPlainText -Force
    $mailCredentials = New-Object System.Management.Automation.PSCredential ($SenderAccount, $securePassword)
    $timestamp = Get-Date -Format s
    $messageArgs = @{
        From          = $SenderAccount
        To            = $ReciverAccount
        SmtpServer    = $SmtpServer
        Port          = $SmtpPort
        Text          = "Test mail!"
        Priority      = 'High'
        Subject       = $timestamp
        Credential    = $mailCredentials
    }
    Write-Host "Sending a test email. Subject: $timestamp"
    Send-EmailMessage @messageArgs -Verbose

    $confirmEmailDeliveryArgs = @{
        Server        = $ImapServer
        Port          = $ImapPort
        Username      = $ReciverAccount
        Password      = $ReciverPassword
        SearchFrom    = $SenderAccount
        SearchSubject = $timestamp
    }
    Write-Host "Starting email delivery check..."
    Invoke-Retry -ScriptBlock { Confirm-EmailDelivery @confirmEmailDeliveryArgs } -MaxAttempts $MaxAttempts -DelaySeconds $DelaySeconds
}
finally {
    Stop-Transcript
}