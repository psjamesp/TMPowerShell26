<#
.SYNOPSIS
    Module 5 Demo: Module Manifests & Version Control Strategy

.DESCRIPTION
    Generates a real .psd1 manifest for the MyToolkit sample module and
    covers semantic versioning and Git-based version control practices
    for PowerShell script/module repositories.

.NOTES
    Workshop Day 2 - Module 5: Module Development & Reusability
    Run this once to create MyToolkit.psd1 before running 01-CreateModule.ps1.
#>

$moduleFolder = 'C:\scripts\TMWorkshop26\Day2-Mod5-Modules\MyToolkit'
$manifestPath = Join-Path $moduleFolder 'MyToolkit.psd1'

$moduleManifestParams = @{
    Path              = $manifestPath
    RootModule        = 'MyToolkit.psm1'
    ModuleVersion     = '1.0.0'
    Author            = 'Workshop Student'
    CompanyName       = 'Contoso IT'
    Description       = 'Sample toolkit built during the PowerShell Automation Workshop.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-DiskSpaceReport', 'New-RandomPassword')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}

New-ModuleManifest @moduleManifestParams

#region Inspecting the manifest
# --- Inspecting the manifest -------------------------------------------
# New-ModuleManifest is silent, so read the manifest back instead - this both
# proves the file was created and validates that it parses.
Test-ModuleManifest -Path $manifestPath | Select-Object Name, Version, Author, ExportedFunctions, Path

#endregion

#region Semantic versioning for scripts and modules
# --- Semantic versioning for scripts and modules -----------------------
# MAJOR.MINOR.PATCH
#   1.0.0 -> 1.0.1  PATCH: bug fix, no behavior change for callers
#   1.0.0 -> 1.1.0  MINOR: new function/parameter added, backward compatible
#   1.0.0 -> 2.0.0  MAJOR: breaking change (renamed/removed parameter, changed output shape)
#
# Bump ModuleVersion in the .psd1 every time you publish a change.

#endregion

#region Version control strategy talking points
# --- Version control strategy talking points --------------------------------
# Recommended repo layout:
#   /Modules/MyToolkit/...      (versioned modules)
#   /Scripts/                   (standalone automation scripts)
#   /Tests/                     (Pester tests, mirrors /Modules structure)
#   README.md, CHANGELOG.md
#
# Git practices to emphasize:
#   - .gitignore: exclude *.log, credential files, local test output
#   - Tag releases matching ModuleVersion, e.g. git tag v1.1.0
#   - Use a CHANGELOG.md entry per version bump
#   - Protect main/master branch; require PR review for shared modules
#   - Pair with Pester tests so CI can validate before merge/publish

#endregion

#region Quick Pester smoke test example (bridges to CI/CD conversation)
# --- Quick Pester smoke test example (bridges to CI/CD conversation) -------
# Save as MyToolkit.Tests.ps1 and run with Invoke-Pester (requires the Pester module):
#
# Describe "Get-DiskSpaceReport" {
#     It "Returns at least one drive" {
#         $result = Get-DiskSpaceReport
#         $result.Count | Should -BeGreaterThan 0
#     }
#     It "PercentFree is between 0 and 100" {
#         $result = Get-DiskSpaceReport
#         foreach ($drive in $result) {
#             $drive.PercentFree | Should -BeGreaterOrEqual 0
#             $drive.PercentFree | Should -BeLessOrEqual 100
#         }
#     }
# }
#endregion
