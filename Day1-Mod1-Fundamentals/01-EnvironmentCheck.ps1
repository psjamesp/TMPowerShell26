<#
.SYNOPSIS
    Module 1 Demo: PowerShell Environment & Version Check

.DESCRIPTION
    Demonstrates how to inspect the PowerShell environment, compare
    Windows PowerShell 5.1 vs PowerShell 7.x, and confirm key settings
    before students start scripting.

.NOTES
    Workshop Day 1 - Module 1: PowerShell Fundamentals & Environment
    Run this on both PS 5.1 (powershell.exe) and PS 7.x (pwsh.exe) to
    compare output live with the class.
#>

#region 1. Version and edition
# The single most important fact to know before scripting: what version/edition
# am I running? Desktop = 5.1 (built on .NET Framework), Core = 7.x (built on
# .NET / cross-platform). PSEdition is one of the rows in this table.
$PSVersionTable
#endregion

#region 2. Host and OS details
# Where does PowerShell live, and which host is executing this?
# Emitting one object instead of three printed lines means this can be piped,
# filtered, or exported later - printed text can't.
[PSCustomObject]@{
    HostName   = $Host.Name
    Executable = $PSHome
    OS         = [System.Environment]::OSVersion.VersionString
}
#endregion

#region 3. Execution policy
# Controls whether scripts are allowed to run at all.
Get-ExecutionPolicy -List
#endregion

#region 4. Module auto-loading paths
# Where PowerShell looks for modules.
$env:PSModulePath -split ";"
#endregion

#region 5. PS 5.1 vs 7.x compatibility note
# Quick compatibility note for the class:
#  - PS 5.1 ships in Windows and cannot be uninstalled; some legacy modules
#    (e.g., older ActiveDirectory, AzureRM) only work here.
#  - PS 7.x is the actively developed, cross-platform version; prefer it
#    for new automation unless a specific module forces 5.1.
if ($PSVersionTable.PSVersion.Major -ge 7) {
    "PowerShell 7+: ternary operator and null-coalescing are available."
    $sample = $null
    $result = $sample ?? "default value"
    "  Null-coalescing demo: $result"
}
else {
    Write-Warning "Windows PowerShell 5.1 detected. Some PS7-only syntax (??, ?:) is unavailable."
}
#endregion
