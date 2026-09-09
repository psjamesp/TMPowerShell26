EXERCISE 5 - Build Your Own Module

This folder is your scaffold. By the end of the exercise it should contain:

  YourToolkit.psm1        <- two functions from Day 1 (yours or the samples)
  YourToolkit.psd1        <- generated with New-ModuleManifest
  CHANGELOG.md            <- one line noting v1.0.0 initial release

Steps:
1. Create YourToolkit.psm1 with two functions and Export-ModuleMember at the bottom.
2. Run New-ModuleManifest to generate YourToolkit.psd1 (see Day 2 Module 5,
   file 02-ModuleManifest.ps1, for the exact syntax).
3. From a separate test script, Import-Module .\YourToolkit.psd1 -Force and
   call both functions to confirm they work.
4. Create CHANGELOG.md with:
     ## 1.0.0
     - Initial release: <function 1>, <function 2>
5. Bonus: bump to 1.1.0 after adding a third function, and add a matching
   CHANGELOG entry.
