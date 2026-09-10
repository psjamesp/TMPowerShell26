<#
.SYNOPSIS
    Module 5 Demo: Creating and Managing PowerShell Modules

.DESCRIPTION
    Walks through turning a folder of functions into a real, importable
    module: folder structure, manifest creation with New-ModuleManifest,
    importing, discovering exported commands, and versioning basics.

.NOTES
    Workshop Day 2 - Module 5: Module Development & Reusability
    Companion files: MyToolkit\MyToolkit.psm1, 02-ModuleManifest.ps1
#>

#region Standard module folder structure
# --- Standard module folder structure ---------------------------------
# Expected layout:
#   MyToolkit\
#     MyToolkit.psm1             <- the actual functions (see companion file)
#     MyToolkit.psd1             <- the manifest (metadata + what to export)
#     en-US\
#       about_MyToolkit.help.txt <- optional conceptual help

#endregion
import-module .\Day2-Mod5-Modules\MyToolkit\MyToolkit.psm1


#region Importing a module from a local path
# --- Importing a module from a local path -----------------------------------
$modulePath = Join-Path $PSScriptRoot 'MyToolkit\MyToolkit.psd1'
if (Test-Path $modulePath) {
    # -PassThru returns the PSModuleInfo object, so the import reports itself
    # without a separate print statement.
    Import-Module $modulePath -Force -PassThru | Select-Object Name, Version, Path
}
else {
    Write-Warning "Run 02-ModuleManifest.ps1 first to generate the .psd1 manifest."
}

#endregion

#region Discovering what a module exposes
# --- Discovering what a module exposes --------------------------------------
Get-Command -Module MyToolkit

#endregion

#region Using the module's functions
# --- Using the module's functions -------------------------------------------
Get-DiskSpaceReport | Format-Table -AutoSize
New-RandomPassword -Length 20

#endregion

#region Confirming private functions are NOT exposed
# --- Confirming private functions are NOT exposed ---------------------------
try {
    ConvertTo-CharacterPool -ErrorAction Stop
}
catch {
    "As expected, ConvertTo-CharacterPool is not accessible outside the module."
}

#endregion

#region Where modules live on disk for auto-discovery
# --- Where modules live on disk for auto-discovery --------------------------
# Copy the MyToolkit folder to a path in $env:PSModulePath, e.g.:
#   C:\Users\<you>\Documents\PowerShell\Modules\MyToolkit\   (current user)
#   C:\Program Files\PowerShell\Modules\MyToolkit\           (all users, needs admin)
# Once there, Import-Module MyToolkit works without a full path, and functions auto-load.

#endregion

#region Publishing to a repository (enterprise pattern)
# --- Publishing to a repository (enterprise pattern) -------------------------
# Awareness level for this workshop:
#   Publish-Module -Path .\MyToolkit -Repository InternalGallery -NuGetApiKey $key
# Most enterprises host an internal NuGet/PowerShell gallery for approved modules.
#endregion
