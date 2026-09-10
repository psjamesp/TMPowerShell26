<#
.SYNOPSIS
    Module 2 Demo: Essential Cmdlets for Daily Operations

.DESCRIPTION
    Covers the cmdlets IT pros reach for constantly: filtering, sorting,
    selecting, exporting, and measuring. Designed to be run block-by-block
    in front of the class.

.NOTES
    Workshop Day 1 - Module 2: Cmdlets, Functions & Pipeline Mastery
#>

#region Filtering
# --- Filtering ---------------------------------------------------------
get-service *win*
get-service | where-object { $_.Name -like '*win*' }

Get-Process | Where-Object { $_.WorkingSet -gt 100MB } |
Select-Object Name, @{N = 'MemoryMB'; E = { [math]::Round($_.WorkingSet / 1MB, 1) } }

# Simplified comparison syntax (PS 3.0+)
$stoppedService = Get-Service | Where-Object Status -eq 'Stopped' | Select-Object -First 5 Name, Status

$service = "bits"

#endregion

#region Sorting
# --- Sorting -------------------------------------------------------------
Get-ChildItem C:\Windows\System32\*.dll -ErrorAction SilentlyContinue |
Sort-Object Length -Descending |
Select-Object -First 5 Name, Length

#endregion

#region Selecting / shaping data
# --- Selecting / shaping data ---------------------------------------------
Get-Process | Select-Object -Property Name, Id, CPU -First 5 | gm
Get-Process | Select-Object -ExpandProperty Name -First 5 | gm

$proc = Get-Process | Select-Object -ExpandProperty Name -First 5

# Calculated properties are one of the most useful, least-known features
Get-Process | Select-Object Name, @{Name = 'MemoryMB'; Expression = { [math]::Round($_.WS / 1MB, 2) } } -First 5
Get-Process | Select-Object Name, @{Name = 'MemoryTB'; Expression = { [math]::Round($_.WS / 1TB, 2) } } -First 5
Get-Process | Select-Object Name, @{Name = 'MemoryGB'; Expression = { [math]::Round($_.WS / 1GB, 2) } } -First 5


#endregion

#region Grouping and measuring
# --- Grouping and measuring -------------------------------------------------
Get-Process | Group-Object -Property Company | Sort-Object Count -Descending | Select-Object -First 5 Count, Name
Get-Process | Measure-Object -Property WorkingSet -Sum -Average -Maximum

Get-Process | Measure-Object -Property WorkingSet -Sum -Average -Maximum | select-object Count
(Get-Process | Measure-Object -Property WorkingSet -Sum -Average -Maximum).Count

#endregion

#region Exporting data
# --- Exporting data --------------------------------------------------------
$exportPath = Join-Path $env:TEMP 'processes.csv'
Get-Process | Select-Object Name, Id, CPU | Export-Csv .\preocessexporft.csv

get-service | where-object { $_.Status -eq 'Running' } | Select-Object Name, Status | out-file .\service.txt

# Export-Csv writes nothing to the pipeline, so hand back the file it created -
# a FileInfo object the caller can pipe onward, not a printed sentence.
Get-Item -Path $exportPath

Get-Process | Select-Object -First 3 Name, Id | ConvertTo-Json
Get-Process | Select-Object -First 3 Name, Id | ConvertTo-Json | out-file .\process.json

$procitems = get-content .\process.json | ConvertFrom-Json

