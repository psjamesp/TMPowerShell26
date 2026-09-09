<#
.SYNOPSIS
    EXERCISE 1 - Environment Sanity Check

.INSTRUCTIONS
    Complete the TODOs below. Goal: report the PowerShell version, edition,
    execution policy, and OS, then a clear PASS/WARN about whether this
    machine meets the workshop minimum (PowerShell 5.1+).

    Style rule for this workshop: let commands emit their output instead of
    wrapping everything in Write-Host. Real data goes to the success stream
    (where it can be piped, filtered, and exported); genuine problems go to
    Write-Warning or Write-Error.
#>

# TODO 1: Output the PowerShell version and edition from $PSVersionTable

# TODO 2: Output the current execution policy for the current scope
#   Hint: Get-ExecutionPolicy

# TODO 3: Output basic OS info
#   Hint: [System.Environment]::OSVersion.VersionString

# TODO 4: Compare $PSVersionTable.PSVersion.Major to 5 and either:
#   emit the string "PASS - meets minimum PowerShell version"
#   or
#   call Write-Warning "Please upgrade PowerShell before Day 2"

# BONUS: Combine TODOs 1-3 into a single [PSCustomObject] so the whole check
#        is one object you could pipe to Export-Csv or ConvertTo-Json.
