<#
.SYNOPSIS
    Module 3 Demo: Error Handling and Debugging

.DESCRIPTION
    Covers terminating vs. non-terminating errors, try/catch/finally,
    -ErrorAction / -ErrorVariable, and basic debugging techniques
    (Write-Verbose, breakpoints, $Error).

.NOTES
    Workshop Day 1 - Module 3: Scripting & Object Manipulation
#>

#region Terminating vs. non-terminating errors
# --- Terminating vs. non-terminating errors ----------------------------
# Non-terminating: the error is written to the error stream and the script
# carries on to the next statement.
Get-Item -Path 'C:\DoesNotExist.txt' -ErrorAction SilentlyContinue
"Script continued after the error above."

# -ErrorAction Stop promotes it to a terminating error, so catch can see it.
try {
    Get-Item -Path 'C:\DoesNotExist.txt' -ErrorAction Stop
}
catch {
    Write-Warning "Caught it: $($_.Exception.Message)"
}

#endregion

#region try / catch / finally
# --- try / catch / finally --------------------------------------------
function Get-FileContentSafely {
    param([Parameter(Mandatory)][string]$Path)

    try {
        $content = Get-Content -Path $Path -ErrorAction Stop
        Write-Verbose "Read $($content.Count) lines."
        return $content
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        Write-Warning "File not found: $Path"
    }
    catch {
        Write-Warning "Unexpected error: $($_.Exception.GetType().Name) - $($_.Exception.Message)"
    }
    finally {
        Write-Verbose "Attempt to read '$Path' complete."
    }
}
Get-FileContentSafely -Path 'C:\Windows\System32\drivers\etc\hosts' -Verbose
Get-FileContentSafely -Path 'C:\NoSuchFile.txt' -Verbose

#endregion

#region Capturing errors without stopping: -ErrorVariable
# --- Capturing errors without stopping: -ErrorVariable ----------------------
Get-Item 'C:\Nope1.txt', 'C:\Nope2.txt' -ErrorAction SilentlyContinue -ErrorVariable myErrors

# $myErrors holds real ErrorRecord objects, so inspect them like any other
# collection rather than printing them as text.
"Captured $($myErrors.Count) errors without stopping the script."
$myErrors | ForEach-Object { $_.Exception.Message }

#endregion

#region $Error automatic variable
# --- $Error automatic variable ------------------------------------------
# $Error is a running list of every error in the session, newest first.
$Error[0].Exception.Message

#endregion

#region Throwing custom, meaningful errors
# --- Throwing custom, meaningful errors -------------------------------------
function Set-ServerConfig {
    param([Parameter(Mandatory)][int]$Port)

    if ($Port -lt 1 -or $Port -gt 65535) {
        throw "Port $Port is out of the valid range (1-65535)."
    }
    "Configured port $Port"
}
try {
    Set-ServerConfig -Port 99999
}
catch {
    Write-Warning "Validation caught: $_"
}

#endregion

#region Debugging aids
# --- Debugging aids -------------------------------------------------------
# Write-Verbose is the right tool for narration: it's off by default and the
# caller opts in with -Verbose, unlike Write-Host which always prints.
function Get-ComputedValue {
    [CmdletBinding()]
    param([int]$Number)

    Write-Verbose "Starting calculation for $Number"
    $result = $Number * 2
    Write-Verbose "Result is $result"
    $result
}
# Run with -Verbose in class to show the difference
Get-ComputedValue -Number 21 -Verbose

# Talking points for class:
#  - Set-PSBreakpoint -Script .\myscript.ps1 -Line 10
#  - Or in VS Code / ISE: click the gutter to set a breakpoint, then F5.
#endregion
