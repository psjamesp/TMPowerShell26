<#
.SYNOPSIS
    Module 3 Demo: Control Flow - If/Else, Switch, and Loops

.DESCRIPTION
    Covers the branching and looping constructs every PowerShell script needs:
    if/elseif/else, switch, for, foreach (statement), while, and do-while/do-until.
    This is the foundation for "writing and executing PowerShell scripts" -
    taught before objects and error handling because both of those lean on it.

.NOTES
    Workshop Day 1 - Module 3: Scripting & Object Manipulation
#>

#region if / elseif / else
# --- if / elseif / else --------------------------------------------------
if ($true) {
    "This block runs because the condition is true"
}

$freeSpacePercent = 12

-lt Less Than
-le Less than equal to
-gt Greater Than
-ge Greater than equal to
-like Like
-notlike Not Like
-match Match (regex)
-notmatch Not Match (regex)
-eq Equal
-ne Not Equal
$true 
$false

if ($freeSpacePercent -lt 20) {
    Write-Error "CRITICAL: less than 20% free space" -ErrorAction Continue
}

if ($freeSpacePercent -lt 10) {
    Write-Error "CRITICAL: less than 10% free space" -ErrorAction Continue
}
elseif ($freeSpacePercent -lt 20) {
    # The stream already labels this - no need to repeat "WARNING:" in the text.
    Write-Warning "Less than 20% free space"
}
else {
    "OK: plenty of free space"
}
$dime = 10
$dime + 10
"dime" + 10
10 + "dime"
"10" + "dime"
[int]"10" + "dime"
[string]10 + "dime"


"CAT" -eq "cat"
"dog" -eq "cat"
"bo" -eq "b*"
"b*" -eq "bob"

100 -eq 100
100 -ne 200

"bob" -like "b*"
"bob" -notlike "b*"

"Cat" -ceq "cat"
"Cat" -cne "cat"


# Talking point: Write-Warning and Write-Error go to their own streams (3 and 2),
# separate from the success stream - a real script can react to or redirect them
# independently of its actual output. Reach for these instead of a colored
# Write-Host whenever the message is a genuine warning or error, not just
# narration. The healthy case isn't a warning at all, so it's a plain value on
# the success stream - which is why it can be captured, piped, or ignored.

# Comparison operators reminder: -eq -ne -gt -ge -lt -le -like -match -contains
# Logical operators: -and -or -not / !
Stream 1 = Success
Stream 2 = Error
Stream 3 = Warning
Stream 4 = Verbose
Stream 5 = Debug
Steam 6 = Information
stream 7 = Progress

write-host "this is a message to the console, not the success stream"

for ($progress = 1; $progress -le 15; $progress++) {
    Write-Progress -Activity "Demo" -Status "Step $progress of 15" -PercentComplete (($progress / 15) * 100)
    Start-Sleep -Milliseconds 100
}

$serviceStatus = 'Stopped'
$startType = 'Automatic'
if ($serviceStatus -eq 'Stopped' -and $startType -eq 'Automatic') {
    Write-Warning "This service should be running but isn't - worth investigating."
}

#endregion

#region switch: cleaner than a long if/elseif chain
# --- switch: cleaner than a long if/elseif chain ---------------------------
function Get-StatusLabel {
    param([int]$ExitCode)
    switch ($ExitCode) {
        0 { "Success" }
        1 { "General error" }
        { $_ -in 2, 3, 4 } { "Known recoverable error" }
        default { "Unknown exit code: $ExitCode" }
    }
}
# No Write-Host needed - each switch arm evaluates to a string, and the
# function returns it straight to the output stream like any cmdlet would.
Get-StatusLabel -ExitCode 0
Get-StatusLabel -ExitCode 3
Get-StatusLabel -ExitCode 99

# switch can also loop over a collection, matching each item - still just
# emitting values, not printing them
switch (@('Running', 'Stopped', 'Paused')) {
    'Running' { "$_ -> healthy" }
    'Stopped' { "$_ -> needs attention" }
    default { "$_ -> unrecognized state" }
}

#endregion

#region for: when you need a counter
# --- for: when you need a counter ------------------------------------------
for ($i = 1; $i -le 5; $i++) {
    "Attempt $i of 5"   # unassigned expression -> flows straight to output
}

#endregion

#region foreach (statement) vs ForEach-Object (cmdlet)
# --- foreach (statement) vs ForEach-Object (cmdlet) -------------------------
$servers = 'SRV-WEB01', 'SRV-DB01', 'SRV-APP01'

# foreach statement: runs in the current scope, best for scripts/functions
foreach ($s in $servers) {
    "Checking $s..."
}

# ForEach-Object: a pipeline cmdlet, best when data is already flowing through a pipeline
$servers | ForEach-Object { "Piped check: $_" }

# Rule of thumb: foreach (statement) for an array already in a variable;
# ForEach-Object when you're mid-pipeline (Get-Process | ForEach-Object {...})

#endregion

#region while: repeat as long as a condition is true
# --- while: repeat as long as a condition is true ---------------------------
$retryCount = 0
$maxRetries = 3
$succeeded = $false

while ($retryCount -lt $maxRetries) {
    $retryCount++
    "Connection attempt $retryCount..."
}

do {
    $retryCount++
    "Connection attempt $retryCount..."
} while ($retryCount -lt $maxRetries)

do {
    $retryCount++
    "Connection attempt $retryCount..." 
}
Until ($retryCount -ge $maxRetries)


while (-not $succeeded -and ($retryCount -lt $maxRetries)) {
    $retryCount++
    "Connection attempt $retryCount..."
    # Simulate success on the 2nd try
    if ($retryCount -eq 2) { $succeeded = $true }
}
"Result: $(if ($succeeded) { 'Connected' } else { 'Gave up' })"

#endregion

#region do-while / do-until: always run the body at least once
# --- do-while / do-until: always run the body at least once -----------------
$attempt = 0
do {
    $attempt++
    "do-while attempt $attempt"
} while ($attempt -lt 3)

$attempt = 0
do {
    $attempt++
    "do-until attempt $attempt"
} until ($attempt -ge 3)

#endregion

#region break and continue
# --- break and continue -----------------------------------------------------
foreach ($n in 1..10) {
    if ($n -eq 3) { continue }   # skip just this iteration
    if ($n -eq 6) { break }      # stop the loop entirely
    "n = $n"
}

# fizzbuzz with if statement and -and
1..100 | ForEach-Object {
    if (($_ % 3 -eq 0) -and ($_ % 5 -eq 0)) { "FizzBuzz" }
    elseif ($_ % 3 -eq 0) { "Fizz" }
    elseif ($_ % 5 -eq 0) { "Buzz" }
    else { $_ }
}

# fizzbuzz with switch and condition expressions
1..100 | ForEach-Object {
    switch ($_) {
        { ($_ % 3 -eq 0) -and ($_ % 5 -eq 0) } { "FizzBuzz" }
        { $_ % 3 -eq 0 } { "Fizz" }
        { $_ % 5 -eq 0 } { "Buzz" }
        default { $_ }
    }
}

