<#
.SYNOPSIS
    Module 2 Demo: Leveraging the Pipeline

.DESCRIPTION
    Shows how the pipeline passes whole .NET objects (not text) between
    commands, why that matters, and how to inspect what's flowing through it.

.NOTES
    Workshop Day 1 - Module 2: Cmdlets, Functions & Pipeline Mastery
#>

#region The pipeline passes OBJECTS, not text
# --- The pipeline passes OBJECTS, not text ----------------------------------
Get-Process | Get-Member | Select-Object -First 10 Name, MemberType

# Compare to a text-based shell mindset (what NOT to do)
# Bad habit carried over from cmd/bash: parsing formatted text
# Get-Process | Out-String | Select-String "chrome"   # fragile!

# Good habit: filter on the real property before formatting
Get-Process -Name "*explorer*" -ErrorAction SilentlyContinue |
Select-Object Name, Id, CPU

Get-Process -Name "*explorer*" -ErrorAction `
    SilentlyContinue | Select-Object Name, Id, CPU
#endregion

#region ForEach-Object: acting on each object in the pipeline
# --- ForEach-Object: acting on each object in the pipeline ------------------
1..5 | ForEach-Object { $_ * $_ }
1..5 | ForEach-Object { write-host "the number in the pipleine is " $_ }

$service = "bits", "spooler"

$service | ForEach-Object { Get-Service -Name $_ }
$service | ForEach-Object { Restart-Service -Name $_ }

foreach ($s in $service) {
    Get-Service -Name $s
}
foreach ($s in $service) {
    Restart-Service -Name $s
}
foreach ($s in $service) {
    stop-Service -Name $s
}

Get-ChildItem -Path $env:TEMP -File | ForEach-Object {
    "{0} is {1:N0} bytes" -f $_.Name, $_.Length
} | Select-Object -First 5

#endregion

#region Chaining multiple cmdlets: the real power of PowerShell
# --- Chaining multiple cmdlets: the real power of PowerShell ----------------
Get-Process |
Where-Object { $_.WorkingSet -gt 50MB } |
Sort-Object WorkingSet -Descending |
Select-Object -First 5 Name, @{N = 'MemoryMB'; E = { [math]::Round($_.WorkingSet / 1MB, 1) } } |
Format-Table -AutoSize

#endregion

#region $_ / $PSItem and pipeline variables
# --- $_ / $PSItem and pipeline variables -------------------------------
1, 2, 3 | ForEach-Object { "Value: $_ | Same as: $PSItem" }

#endregion

#region Building your own pipeline-friendly output
# --- Building your own pipeline-friendly output ------------------------
# The point of this section: the function never prints anything. It emits
# objects, which is exactly why the two calls below can go anywhere.
function Get-TopMemoryProcess {
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 20
}
# Because it emits objects, output can be piped further without any parsing:

$top30proc = get-topmemoryprocess 
Get-TopMemoryProcess | Select-Object Name | Format-Table -AutoSize
Get-TopMemoryProcess | Export-Csv -Path (Join-Path $env:TEMP 'top-mem.csv') -NoTypeInformation

#endregion

#region Performance note for advanced students
# --- Performance note for advanced students -----------------------------
# Pipeline: elegant, streams one object at a time (low memory).
# foreach() keyword: often faster for large in-memory collections.
# Rule of thumb: pipeline for readability & streaming; foreach() for tight loops on arrays already in memory.
#endregion
