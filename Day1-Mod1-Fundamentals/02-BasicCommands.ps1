<#
.SYNOPSIS
    Module 1 Demo: Console Navigation & Basic Command Execution

.DESCRIPTION
    A guided tour of the core "verbs" every PowerShell user needs on day one:
    discovering commands, reading help, navigating the filesystem provider,
    and running your first cmdlets.

.NOTES
    Workshop Day 1 - Module 1: PowerShell Fundamentals & Environment
    Talking point: PowerShell's Verb-Noun naming convention makes commands
    discoverable and predictable.
#>

#region Discovering commands
# --- Discovering commands -------------------------------------------------

# Find every command with a given verb
Get-Command -Verb Get -Noun *Service* | Select-Object -First 5

# List approved verbs - reinforces the Verb-Noun convention
Get-Verb | Select-Object -First 10 | Format-Table -AutoSize

Get-Service -name *service*
get-service *service*

#endregion

#region Getting help
# --- Getting help ----------------------------------------------------------
# Run these interactively with students:
Get-Help Get-Process
Get-Help Get-Process -Examples
Get-Help Get-Process -Full
Get-Help Get-Process -ShowWindow
Update-Help   # requires admin + internet, run once before class

Get-Member

get-service  | Get-Member
get-service bits 


#endregion

#region Navigating the filesystem provider
# --- Navigating the filesystem provider ------------------------------------
Get-Location

set-location
CD

get-childitem
dir
ls

# PowerShell "drives" aren't just disks - Env:, HKLM:, Cert: are all providers
Get-PSDrive | Format-Table Name, Provider, Root -AutoSize

#endregion

#region Running your first real cmdlets
# --- Running your first real cmdlets ---------------------------------------
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU, Id
Get-Service | Where-Object Status -eq 'Running' | Select-Object -First 5 Name, DisplayName
Get-ChildItem -Path $env:TEMP | Select-Object -First 5 Name, Length, LastWriteTime

#endregion

#region Aliases: convenient, but know the real cmdlet name
# --- Aliases: convenient, but know the real cmdlet name --------------------
# Convenient in the console, but spell out the real cmdlet in shared scripts.
# Get-Alias already returns objects, so one call replaces four printed lines.
Get-Alias ls, gci, '?', '%' | Format-Table Name, ResolvedCommandName -AutoSize
#endregion
