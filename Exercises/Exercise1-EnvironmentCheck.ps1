<#
.SYNOPSIS
    EXERCISE 1 - Environment Sanity Check

.INSTRUCTIONS
    Complete the TODOs below. Goal: print PowerShell version, edition,
    execution policy, and OS, then a clear PASS/WARN line about whether
    this machine meets the workshop minimum (PowerShell 5.1+).
#>

# TODO 1: Print the PowerShell version and edition from $PSVersionTable

# TODO 2: Print the current execution policy for the current scope
#   Hint: Get-ExecutionPolicy

# TODO 3: Print basic OS info
#   Hint: [System.Environment]::OSVersion.VersionString

# TODO 4: Compare $PSVersionTable.PSVersion.Major to 5 and print either:
#   "PASS - meets minimum PowerShell version" (green)
#   or
#   "WARN - please upgrade PowerShell before Day 2" (yellow)
#   Hint: Write-Host -ForegroundColor Green / Yellow
