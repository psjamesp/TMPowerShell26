<#
.SYNOPSIS
    Module 2 Demo: Creating Custom Functions

.DESCRIPTION
    Progresses from a simple function to a fully parameterized, pipeline-
    aware, documented function — mirroring the pattern used in production
    PowerShell modules.

.NOTES
    Workshop Day 1 - Module 2: Cmdlets, Functions & Pipeline Mastery
#>

#region Step 1: The simplest possible function
# --- Step 1: The simplest possible function --------------------------------
function Get-Greeting {
    "Hello from PowerShell!"
}
Get-Greeting

#endregion

#region Step 2: Parameters
# --- Step 2: Parameters ------------------------------------------------
function Get-PersonalGreeting {
    param(
        $Name = "World"
    )
    "Hello, $Name!"
}
Get-PersonalGreeting -Name "Class"
Get-PersonalGreeting
#endregion

#region Step 3: Typed, mandatory parameters with validation
# --- Step 3: Typed, mandatory parameters with validation --------------------
function Get-DiskUsageReport {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z]:$')]
        [string]$DriveLetter,

        [ValidateRange(1, 100)]
        [int]$WarningThresholdPercent = 80
    )

    $drive = Get-PSDrive -Name $DriveLetter.TrimEnd(':') -ErrorAction Stop
    $usedPercent = [math]::Round((($drive.Used) / ($drive.Used + $drive.Free)) * 100, 1)

    [PSCustomObject]@{
        Drive       = $DriveLetter
        UsedGB      = [math]::Round($drive.Used / 1GB, 2)
        FreeGB      = [math]::Round($drive.Free / 1GB, 2)
        UsedPercent = $usedPercent
        Warning     = $usedPercent -ge $WarningThresholdPercent
    }
}
Get-DiskUsageReport -DriveLetter C:

#endregion

#region Step 4: A full, pipeline-aware, documented function
# --- Step 4: A full, pipeline-aware, documented function --------------------
function Test-ServiceHealth {
    <#
    .SYNOPSIS
        Checks whether one or more services are running and reports status.
    .PARAMETER Name
        One or more service names. Accepts pipeline input.
    .EXAMPLE
        Test-ServiceHealth -Name Spooler, BITS
    .EXAMPLE
        'Spooler','BITS' | Test-ServiceHealth
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Name
    )

    process {
        foreach ($svcName in $Name) {
            $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
            if (-not $svc) {
                Write-Warning "Service '$svcName' not found."
                continue
            }
            [PSCustomObject]@{
                Service   = $svc.Name
                Status    = $svc.Status
                StartType = $svc.StartType
                Healthy   = $svc.Status -eq 'Running'
            }
        }
    }
}

# Three equivalent ways to call it - great talking point for pipeline vs. args
Test-ServiceHealth -Name 'Spooler', 'BITS'
'Spooler', 'BITS' | Test-ServiceHealth
Get-Service -Name Spooler | Test-ServiceHealth
#endregion
