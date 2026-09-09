<#
.SYNOPSIS
    EXERCISE 3 - Safe File Batch Processor

.INSTRUCTIONS
    Write a function Get-FileProcessingSummary that:
      - Accepts an array of file paths (pipeline-friendly)
      - For each path, tries to read the file with Get-Content
      - On success: returns an object {Path, Success=$true, LineCount, Error=$null}
      - On failure: catches the error and returns {Path, Success=$false, LineCount=$null, Error=<message>}
      - Never lets one bad path stop the whole batch
    Test with a mix of real and fake file paths.
#>

function Get-FileProcessingSummary {
    [CmdletBinding()]
    param(
        # TODO 1: Add a [string[]]$Path parameter, mandatory, pipeline-enabled
    )

    process {
        foreach ($p in $Path) {
            # TODO 2: try { } catch { } around Get-Content -Path $p -ErrorAction Stop

            # TODO 3: On success, output a [PSCustomObject] with
            #         Path, Success=$true, LineCount=<content.Count>, Error=$null

            # TODO 4: On failure (in the catch block), output a [PSCustomObject] with
            #         Path, Success=$false, LineCount=$null, Error=$_.Exception.Message
        }
    }
}

# TODO 5: Test it, e.g.:
# 'C:\Windows\System32\drivers\etc\hosts', 'C:\DoesNotExist.txt' | Get-FileProcessingSummary
