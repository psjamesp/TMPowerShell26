<#
.SYNOPSIS
    Module 3 Demo: Working with Objects and Properties

.DESCRIPTION
    Demonstrates PSCustomObject creation, property access, type inspection,
    and converting between object shapes — the core skill for turning raw
    data into usable automation output.

.NOTES
    Workshop Day 1 - Module 3: Scripting & Object Manipulation
#>

#region Inspecting an object's type and members
# --- Inspecting an object's type and members --------------------------------
$proc = Get-Process | Select-Object -First 1
$proc.GetType().FullName
$proc | Get-Member -MemberType Property | Select-Object -First 8

$proc | select-object -expandproperty Name
$proc.Id

$proc.kill()
$proc | stop-process -Force
#endregion

#region Creating custom objects: the standard way to shape output
# --- Creating custom objects: the standard way to shape output --------------
# Preferred modern syntax
$server = [PSCustomObject]@{
    Name        = 'SRV-WEB01'
    Environment = 'Production'
    CPUCores    = 8
    RAMGB       = 32
    LastPatched = Get-Date
}
$server

$server.RAMGB
$server | select-object RAMGB

# Building an array of custom objects (this is what most reports look like)
$servers = @(
    [PSCustomObject]@{ Name = 'SRV-WEB01'; RoleTag = 'Web'; Status = 'Online' }
    [PSCustomObject]@{ Name = 'SRV-DB01'; RoleTag = 'Database'; Status = 'Online' }
    [PSCustomObject]@{ Name = 'SRV-APP01'; RoleTag = 'Application'; Status = 'Offline' }
)
$servers | Format-Table -AutoSize
$servers | Where-Object Status -eq 'Online' | Select-Object Name, RoleTag

#endregion

#region Adding properties to existing objects
# --- Adding properties to existing objects ----------------------------------
$server | Add-Member -MemberType NoteProperty -Name Location -Value 'East US'
$server

#endregion

#region Type conversion: PSCustomObject <-> Hashtable <-> JSON
# --- Type conversion: PSCustomObject <-> Hashtable <-> JSON -----------------
$json = $server | ConvertTo-Json
$json
$roundTripped = $json | ConvertFrom-Json
$roundTripped.GetType().FullName   # Note: PSCustomObject again, not Hashtable

# Hashtable to object and back (common in config files)
$configHash = @{ Timeout = 30; RetryCount = 3 }
$configObj = [PSCustomObject]$configHash
$configObj

#endregion

#region Practical pattern: build a report object from multiple sources
# --- Practical pattern: build a report object from multiple sources --------
$report = Get-Service | Where-Object Status -eq 'Running' | ForEach-Object {
    [PSCustomObject]@{
        ServiceName = $_.Name
        DisplayName = $_.DisplayName
        StartType   = $_.StartType
        CheckedAt   = Get-Date -Format 'yyyy-MM-dd HH:mm'
    }
}
$report | Select-Object -First 5 | Format-Table -AutoSize
#endregion
$report.psobject.Properties.remove('CheckedAt')
$report