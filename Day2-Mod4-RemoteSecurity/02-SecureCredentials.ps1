<#
.SYNOPSIS
    Module 4 Demo: Security Best Practices & Secure Credential Management

.DESCRIPTION
    Demonstrates the SecureString / PSCredential pattern, why plaintext
    credentials in scripts are dangerous, encrypted credential storage on
    disk, and a first look at the SecretManagement module for enterprise use.

.NOTES
    Workshop Day 2 - Module 4: Remote Administration & Security
    IMPORTANT: Emphasize to students that Get-Credential is interactive and
    is the ONLY acceptable way to collect a password in a live demo. Never
    type a real password into a script or terminal in front of the class.
#>

[CmdletBinding()]
param(
    [switch]$SaveCredential,
    [switch]$RunSecretManagementDemo,
    [string]$CredentialPath = (Join-Path $PSScriptRoot 'svc-account.cred')
)


function Read-DemoCredential {
    Get-Credential -Message 'Enter the demo account credentials'
}

function Save-DemoCredential {
    param(
        [Parameter(Mandatory)]
        [pscredential]$Credential,
        [Parameter(Mandatory)]
        [string]$Path
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -Path $parent -ItemType Directory -Force | Out-Null
    }

    $Credential.Password | ConvertFrom-SecureString | Set-Content -LiteralPath $Path
    Write-Host "Encrypted password saved to $Path"
}

function Read-DemoCredentialFromFile {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$UserName
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Credential file not found: $Path"
    }

    $encryptedPassword = Get-Content -LiteralPath $Path | ConvertTo-SecureString
    [pscredential]::new($UserName, $encryptedPassword)
}

#region The wrong way (show this ONLY to explain why it's dangerous)
# --- The wrong way (show this ONLY to explain why it's dangerous) ----------
# ANTI-PATTERN - never do either of these:
#   $password = "SuperSecret123"                         # plaintext in script
#   net use \\server\share /user:admin SuperSecret123    # visible in process list

#endregion

#region The right way: Get-Credential + SecureString
# --- The right way: Get-Credential + SecureString ---------------------------
# A PSCredential bundles a username with a SecureString password.
# Never call ConvertFrom-SecureString -AsPlainText except in throwaway demos.
#

$cred = Read-DemoCredential
$cred.UserName
$cred.Password.GetType().FullName


#endregion

#region Saving encrypted credentials to disk (per-user, per-machine)
# --- Saving encrypted credentials to disk (per-user, per-machine) -----------
# DPAPI-encrypted: this only decrypts correctly for the SAME user on the SAME
# machine, which is both the feature and the limitation.
$CredentialPath = 'C:\scripts\TMWorkshop26\cred\cred.txt'
Save-DemoCredential -Credential $cred -Path $CredentialPath
$storedCred = Read-DemoCredentialFromFile -Path $CredentialPath -UserName $cred.UserName
Write-Host "Credential loaded successfully for $($storedCred.UserName)"


#endregion

#region Enterprise pattern: SecretManagement module
# --- Enterprise pattern: SecretManagement module ----------------------------

$requiredModules = 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore'
foreach ($moduleName in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Warning "Install $moduleName before running this demo."
    }
}

if ((Get-Module -ListAvailable -Name $requiredModules).Count -eq $requiredModules.Count) {
    Import-Module Microsoft.PowerShell.SecretManagement
    Import-Module Microsoft.PowerShell.SecretStore
    if (-not (Get-SecretVault -Name LocalVault -ErrorAction SilentlyContinue)) {
        Register-SecretVault -Name LocalVault -ModuleName Microsoft.PowerShell.SecretStore
    }
    $secret = Read-DemoCredential
    Set-Secret -Name SvcAccountPassword -Secret $secret.Password -Vault LocalVault
    Write-Host 'Secret stored in LocalVault.'
}

get-secret -Name SvcAccountPassword -Vault LocalVault
#endregion

#region JEA (Just Enough Administration) - awareness level for this workshop
# --- JEA (Just Enough Administration) - awareness level for this workshop --
# JEA lets you grant a user remoting access to run only specific, pre-approved
# commands - not a full admin shell. Mention Register-PSSessionConfiguration
# and role capability files as the next step for students securing production remoting.

#endregion

#region Execution policy as a security control (not a security boundary!)
# --- Execution policy as a security control (not a security boundary!) -----
Get-ExecutionPolicy -List
# Talking point: Execution policy prevents accidents, not determined attackers.
# Real controls: code signing, AppLocker/WDAC, JEA, least-privilege service accounts.
#endregion
