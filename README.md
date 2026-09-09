# Hands-On Exercises

Each exercise builds toward the portfolio of reusable scripts referenced in
the course description. Starter files contain `# TODO:` comments; solutions
are provided separately for instructor use.

**Numbering:** Exercise N always matches Module N — Exercise 1 goes with
Module 1, Exercise 5 goes with Module 5, and so on. There's no separate
day-based numbering to track.

## Day 1

### Exercise 1 – Environment Sanity Check (Module 1, ~15 min)
Write a script that reports the PowerShell version, edition, execution
policy, and OS, and prints a clear PASS/WARN for whether the machine meets
the workshop's minimum requirement (PowerShell 5.1+).
**Starter:** `Exercise1-EnvironmentCheck.ps1`

### Exercise 2 – Process/Service Reporter (Module 2, ~20 min)
Write a function `Get-TopResourceConsumers` that accepts `-Type Process`
or `-Type Service` and returns the top N (default 5) by CPU or by running
status, using the pipeline and calculated properties.
**Starter:** `Exercise2-ResourceReporter.ps1`

### Exercise 3 – Safe File Batch Processor (Module 3, ~25 min)
Write a function that takes an array of file paths, tries to read each one,
catches and logs any errors (missing file, access denied) without stopping,
and returns a summary object per file (Path, Success, LineCount, Error).
**Starter:** `Exercise3-BatchFileProcessor.ps1`

## Day 2

### Exercise 4 – Multi-Server Remote Check (Module 4, ~25 min)
Using `Invoke-Command` against the provided lab servers, collect the
Spooler and BITS service status from each and return one object per
server/service pair. Use `Get-Credential` for authentication — never a
hardcoded password.
**Starter:** `Exercise4-RemoteServiceCheck.ps1`

### Exercise 5 – Build Your Own Module (Module 5, ~30 min)
Take two functions you wrote on Day 1 (or the sample ones), place them in
a `.psm1`, generate a manifest with `New-ModuleManifest`, and import/run
them from a separate script. Bump the version and note the change in a
`CHANGELOG.md`.
**Starter:** `Exercise5-ModuleFolder/` (empty scaffold)

### Exercise 6 – Capstone: End-to-End Automation (Module 6, ~40 min)
Extend the `02-EndToEndAutomation.ps1` capstone script from class:
add a parameter to filter to only unhealthy servers in the output, export
to JSON in addition to CSV, and add one Azure resource query (e.g., list
VMs in a resource group) alongside the on-prem health check.
**Starter:** `Exercise6-Capstone.ps1`

---
**Instructor note:** solution files for each exercise are provided in the
`Solutions/` folder distributed separately to instructors to avoid
spoiling the exercises if students browse the shared repo early.
