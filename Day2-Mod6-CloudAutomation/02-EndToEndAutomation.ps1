<#
.SYNOPSIS
    Module 6 Capstone Demo: End-to-End Automation Solution

.DESCRIPTION
    Ties together everything from both workshop days into one realistic
    automation: a multi-server health check that gathers data remotely,
    shapes it into objects, handles errors gracefully, exports a report,
    and emails/logs the results — the shape of a real production script.

.NOTES
    Workshop Day 2 - Module 6: Cloud Integration & Advanced Automation
    This is the "capstone" script - walk through it top to bottom on the
    projector, then have students adapt it to their own environment as
    the final hands-on exercise.
#>

[CmdletBinding()]
param(
    [string[]]$ComputerName = @('dc01', 'srv01', 'srv02'),
    [string]$ReportPath = (Join-Path $env:TEMP "HealthReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"),
    [int]$DiskWarningThreshold = 15   # percent free space
)

function Get-ServerHealthSnapshot {
    <#
    .SYNOPSIS
        Collects CPU, memory, disk, and key service health from a computer.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName,

        [int]$DiskWarningThreshold = 15
    )

    process {
        Write-Verbose "Checking $ComputerName..."
        try {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3" -ErrorAction Stop

            $lowDisks = $disks | Where-Object {
                $_.Size -gt 0 -and (($_.FreeSpace / $_.Size) * 100) -lt $DiskWarningThreshold
            }

            [PSCustomObject]@{
                ComputerName  = $ComputerName
                Status        = 'Online'
                UptimeHours   = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
                FreeMemoryPct = [math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100, 1)
                LowDiskCount  = $lowDisks.Count
                LowDiskDetail = ($lowDisks.DeviceID -join ', ')
                CheckedAt     = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                Error         = $null
            }
        }
        catch {
            # Non-terminating for the overall run: one unreachable server
            # shouldn't stop the whole report.
            Write-Warning "Failed to reach $ComputerName`: $($_.Exception.Message)"
            [PSCustomObject]@{
                ComputerName  = $ComputerName
                Status        = 'Unreachable'
                UptimeHours   = $null
                FreeMemoryPct = $null
                LowDiskCount  = $null
                LowDiskDetail = $null
                CheckedAt     = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                Error         = $_.Exception.Message
            }
        }
    }
}

#region Run the health check across all target servers
# --- Run the health check across all target servers ------------------------
Write-Verbose "Running health check against $($ComputerName.Count) server(s)."
$results = $ComputerName | Get-ServerHealthSnapshot -DiskWarningThreshold $DiskWarningThreshold -Verbose

#endregion

#region Present results in the console
# --- Present results in the console -----------------------------------
$results | Format-Table -AutoSize

#endregion

#region Export the report
# --- Export the report --------------------------------------------------
$results | Export-Csv -Path $ReportPath -NoTypeInformation

# Return the report file as an object rather than announcing it in text - the
# caller can then pipe it straight to Send-MailMessage, Copy-Item, etc.
Get-Item -Path $ReportPath

#endregion

#region Flag anything that needs attention
# --- Flag anything that needs attention -------------------------------
$issues = $results | Where-Object { $_.Status -eq 'Unreachable' -or $_.LowDiskCount -gt 0 }
if ($issues) {
    Write-Warning "$($issues.Count) server(s) need attention:"
    $issues | Format-Table ComputerName, Status, LowDiskDetail, Error -AutoSize
}
else {
    "All servers healthy."
}

#endregion

#region Talking points for extending this into "enterprise-grade"
# --- Talking points for extending this into "enterprise-grade" -------------
# Where this goes next (class discussion):
# - Swap CIM/local queries for Invoke-Command / Az cmdlets to run against
#   on-prem servers or Azure VMs from Module 4 and Module 6.
# - Wrap this in a scheduled task or Azure Automation Runbook for unattended runs.
# - Replace Write-Warning with Send-MailMessage or a Teams/Slack webhook for alerting.
# - Move Get-ServerHealthSnapshot into the MyToolkit module from Module 5.
# - Add Pester tests before promoting this into a shared, versioned module.
# - Store any credentials using the SecretManagement pattern from Module 4.
#endregion
