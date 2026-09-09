<#
.SYNOPSIS
    EXERCISE 6 - Capstone: Extend the End-to-End Automation Script

.INSTRUCTIONS
    Start from ..\Day2-Mod6-CloudAutomation\02-EndToEndAutomation.ps1
    (copy it into this file first), then add:

    1. A new switch parameter -UnhealthyOnly that, when set, filters the
       final $results down to only Status='Unreachable' or LowDiskCount > 0
       before display/export.

    2. In addition to Export-Csv, also export the (possibly filtered)
       results to JSON using ConvertTo-Json | Set-Content, using the same
       base filename with a .json extension.

    3. One Azure resource query: after the on-prem health check, call
       Get-AzVM -ResourceGroupName <your-lab-rg> and append PowerState
       to the console output as a second table (see Module 6,
       01-AzurePowerShellBasics.ps1, for the exact cmdlet syntax).

    Test with -ComputerName localhost first, then against your assigned
    lab servers if time allows.
#>

# TODO: Paste the capstone script here and make the three modifications above.
