<#
    FileNameTools.psm1
    Utilities for cleaning up file and folder names.

    Public:   Rename-SpaceToUnderscore
    Private:  Resolve-TargetItem, New-CleanName
#>

Set-StrictMode -Version Latest

#region Private Functions (not exported)
function New-CleanName {
    <#
        Builds the replacement name for a single item.
        Only the file NAME is touched - the extension is left alone unless it
        somehow contains a space, which the same replacement handles anyway.
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyString()][string]$ReplaceWith,
        [switch]$CollapseRepeats
    )

    # \s catches tabs and non-breaking spaces that sneak in from copy/paste,
    # not just the plain space character.
    $pattern = if ($CollapseRepeats) { '\s+' } else { '\s' }
    $Name -replace $pattern, $ReplaceWith
}

function Resolve-TargetItem {
    <#
        Expands one -Path value into the items that should be renamed.
        A directory is treated as a container to scan; anything else is
        treated as an explicit target.
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Filter,
        [switch]$Recurse,
        [switch]$IncludeDirectory
    )

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop

    if ($item.PSIsContainer) {
        $gciParams = @{
            LiteralPath = $item.FullName
            Filter      = $Filter
            Force       = $true
            Recurse     = [bool]$Recurse
            ErrorAction = 'SilentlyContinue'
        }
        Get-ChildItem @gciParams -File
        if ($IncludeDirectory) { Get-ChildItem @gciParams -Directory }
    }
    else {
        $item
    }
}
#endregion

#region Public Functions (exported)
function Rename-SpaceToUnderscore {
    <#
    .SYNOPSIS
        Renames files (and optionally folders) so every space in the name
        becomes an underscore.

    .DESCRIPTION
        Finds items whose names contain whitespace and renames them in place.
        Items without spaces are left untouched. Supports -WhatIf/-Confirm, so
        always dry-run with -WhatIf before letting it loose on real data.

        Directories are renamed deepest-first so that child paths stay valid
        while the operation is in progress.

    .PARAMETER Path
        One or more directories to scan, or explicit files to rename. Defaults
        to the current directory. Accepts pipeline input from Get-ChildItem.

    .PARAMETER Filter
        Provider filter applied when scanning a directory, e.g. '*.txt'.
        Ignored when Path points directly at a file.

    .PARAMETER Recurse
        Scan subdirectories as well.

    .PARAMETER IncludeDirectory
        Also rename folder names, not just files.

    .PARAMETER ReplaceWith
        String that replaces each space. Defaults to '_'. Pass '' to strip
        spaces entirely. Cannot contain characters illegal in a file name.

    .PARAMETER CollapseRepeats
        Treat a run of consecutive spaces as one, so 'my   file.txt' becomes
        'my_file.txt' instead of 'my___file.txt'.

    .PARAMETER PassThru
        Emit the renamed items. Without it the function is silent.

    .EXAMPLE
        Rename-SpaceToUnderscore -Path C:\Reports -WhatIf

        Dry run: shows every rename that would happen in C:\Reports.

    .EXAMPLE
        Rename-SpaceToUnderscore -Path C:\Reports -Recurse -IncludeDirectory -PassThru

        Renames files and folders through the whole tree and returns the results.

    .EXAMPLE
        Get-ChildItem C:\Data -Filter '*.csv' | Rename-SpaceToUnderscore -CollapseRepeats

        Pipeline input: only the .csv files you selected are renamed.

    .OUTPUTS
        System.IO.FileSystemInfo (with -PassThru)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileSystemInfo])]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName', 'PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path = '.',

        [ValidateNotNullOrEmpty()]
        [string]$Filter = '*',

        [switch]$Recurse,

        [switch]$IncludeDirectory,

        [AllowEmptyString()]
        [ValidateScript({
            $bad = [System.IO.Path]::GetInvalidFileNameChars()
            if ($_.ToCharArray() | Where-Object { $_ -in $bad }) {
                throw "ReplaceWith contains characters that are not legal in a file name."
            }
            $true
        })]
        [string]$ReplaceWith = '_',

        [switch]$CollapseRepeats,

        [switch]$PassThru
    )

    begin {
        $targets = [System.Collections.Generic.List[System.IO.FileSystemInfo]]::new()
    }

    process {
        foreach ($p in $Path) {
            try {
                $found = Resolve-TargetItem -Path $p -Filter $Filter `
                    -Recurse:$Recurse -IncludeDirectory:$IncludeDirectory
                foreach ($f in $found) { $targets.Add($f) }
            }
            catch {
                Write-Error "Cannot access '$p': $($_.Exception.Message)"
            }
        }
    }

    end {
        # Only items that actually contain whitespace are candidates.
        # Files first, then directories deepest-first, so renaming a parent
        # folder never invalidates the stored path of a child still pending.
        $candidates = $targets |
            Sort-Object -Property FullName -Unique |
            Where-Object { $_.Name -match '\s' } |
            Sort-Object -Property @{ Expression = { [bool]$_.PSIsContainer } },
                                  @{ Expression = { $_.FullName.Length }; Descending = $true }

        foreach ($item in $candidates) {
            $newName = New-CleanName -Name $item.Name -ReplaceWith $ReplaceWith `
                -CollapseRepeats:$CollapseRepeats

            if ([string]::IsNullOrWhiteSpace($newName)) {
                Write-Warning "Skipped '$($item.FullName)': the new name would be empty."
                continue
            }

            $parent  = [System.IO.Path]::GetDirectoryName($item.FullName)
            $newPath = Join-Path -Path $parent -ChildPath $newName
            if (Test-Path -LiteralPath $newPath) {
                Write-Warning "Skipped '$($item.FullName)': '$newName' already exists."
                continue
            }

            if ($PSCmdlet.ShouldProcess($item.FullName, "Rename to '$newName'")) {
                try {
                    $renamed = Rename-Item -LiteralPath $item.FullName -NewName $newName `
                        -PassThru -ErrorAction Stop
                    Write-Verbose "Renamed '$($item.Name)' -> '$newName'"
                    if ($PassThru) { $renamed }
                }
                catch {
                    Write-Error "Failed to rename '$($item.FullName)': $($_.Exception.Message)"
                }
            }
        }
    }
}
#endregion

Export-ModuleMember -Function Rename-SpaceToUnderscore
