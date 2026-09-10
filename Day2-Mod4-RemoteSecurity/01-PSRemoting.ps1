<#
.SYNOPSIS
    Module 4 Demo: PowerShell Remoting & Remote Server Management

.DESCRIPTION
    Demonstrates the main remoting patterns: one-off commands with
    Invoke-Command, interactive sessions with Enter-PSSession, reusable
    persistent sessions, CIM sessions, and SSH-based remoting in PowerShell 7.

.NOTES
    Workshop Day 2 - Module 4: Remote Administration & Security
    PREREQUISITE: 'Enable-PSRemoting -Force' must have been run as Administrator
    on each target machine. Lab targets for this workshop: DC01, SRV01, SRV02.

    Run this file a region at a time (Ctrl+Alt+Enter in VS Code / F8 in ISE).
    Only the Enter-PSSession blocks are commented out - they take over the
    prompt and have to be run by hand.
#>

$targetComputer = 'SRV01'
$servers = 'DC01', 'SRV01', 'SRV02'

#region Checking remoting is enabled
# --- Checking remoting is enabled ------------------------------------------
# On each TARGET machine (run once, as Admin):  Enable-PSRemoting -Force
# From the ADMIN machine, Test-WSMan proves the listener is answering:
Test-WSMan -ComputerName $targetComputer

# Same check across the whole lab - never assume all three are reachable
foreach ($server in $servers) {
    try {
        $null = Test-WSMan -ComputerName $server -ErrorAction Stop
        [PSCustomObject]@{ ComputerName = $server; Remoting = 'OK' }
    }
    catch {
        [PSCustomObject]@{ ComputerName = $server; Remoting = "FAILED: $($_.Exception.Message)" }
    }
}

# The local machine's WinRM config (listeners, ports, TrustedHosts):
Get-Service -Name WinRM
winrm enumerate winrm/config/listener

#endregion

#region Interactive remoting
# --- Interactive remoting ---------------------------------------------------
# These take over the prompt, so run them by hand in the console.
# Watch the prompt change to [SRV01]: PS C:\>
#
Enter-PSSession -ComputerName SRV01
hostname
Get-ChildItem C:\
Exit-PSSession

Enter-PSSession -ComputerName SRV01 -Credential (get-credential)
Enter-PSSession -ComputerName SRV01 -Credential 714tech\bob
$cred = get-credential
Enter-PSSession -ComputerName SRV01 -Credential $cred

Enter-PSSession -ComputerName SRV02 -Credential $cred

Enter-PSSession -ComputerName SRV01 -Credential $cred -ConfigurationName PowerShell.7


# Good for troubleshooting one box. Bad for automation - you cannot script
# your way through an interactive prompt.

#endregion
#region One-off remote commands with Invoke-Command
# --- One-off remote commands with Invoke-Command ----------------------------
# Single machine - connect, run, return objects, disconnect:
Invoke-Command -ComputerName $targetComputer -ScriptBlock {
    $env:COMPUTERNAME
    Get-Service -Name Spooler
}

Invoke-Command -ComputerName $servers -ScriptBlock {
    $env:COMPUTERNAME
    Get-Service -Name Spooler
}

Invoke-Command $servers {
    $env:COMPUTERNAME
    Get-Service -Name Spooler
}

# Multiple machines - one connection each, fanned out in parallel:
Invoke-Command -ComputerName $servers -ScriptBlock {
    [PSCustomObject]@{
        OS     = (Get-CimInstance Win32_OperatingSystem).Caption
        Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
       
    }
} | Format-Table PSComputerName, OS, Uptime -AutoSize

# Note what came back: real objects, not text. Remoting adds PSComputerName
# and RunspaceId so you can tell which server each row came from.
Invoke-Command -ComputerName $servers -ScriptBlock { Get-Process -Name svchost } |
Get-Member -MemberType NoteProperty

# Because they are objects, normal pipeline work still applies locally:
Invoke-Command -ComputerName $servers -ScriptBlock { Get-Service } |
Where-Object { $_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic' } |
Select-Object PSComputerName, Name, DisplayName |
Sort-Object PSComputerName, Name

# Errors are per-machine, not fatal to the whole run. Capture them separately:
Invoke-Command -ComputerName ($servers + 'SRV99-DOESNOTEXIST') -ScriptBlock {
    $env:COMPUTERNAME
} -ErrorAction SilentlyContinue -ErrorVariable remotingErrors

$remotingErrors | ForEach-Object { "Unreachable: $($_.TargetObject)" }

invoke-command -ComputerName (get-content .\servers.txt) -scriptblock { hostname } -ErrorAction SilentlyContinue -ErrorVariable remotingErrors
invoke-command -computerName (import-csv .\servers.csv) -scriptblock { hostname } -ErrorAction SilentlyContinue -ErrorVariable remotingErrors

$adcomputers = get-adcomputer -Filter * -SearchBase "ou=printservers,ou=Servers,DC=contoso,DC=com"
invoke-command -computername ($adcomputers | select -ExpandProperty Name)
invoke-command -computername ($adcomputers | select -ExpandProperty Name)

invoke-command -computer (get-adgroupmember -Identity "sccm servers" | select -ExpandProperty samAccountName) -scriptblock { hostname }
#endregion

#region Passing local variables into the remote scriptblock
# --- Passing local variables into the remote scriptblock --------------------
# The remote session is a separate PowerShell process - it has never heard of
# your local variables. This one returns nothing useful:
$serviceName = 'BITS'
Invoke-Command -ComputerName $targetComputer -ScriptBlock { Get-Service -Name $serviceName }

# Option 1 - param() + -ArgumentList (works on every PowerShell version):
Invoke-Command -ComputerName $targetComputer -ScriptBlock {
    param($svc)
    Get-Service -Name $svc
} -ArgumentList $serviceName

# Option 2 - the $using: scope modifier (cleaner, PS 3.0+):
Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Service -Name $using:serviceName | Select-Object Name, Status, StartType
} | Format-Table PSComputerName, Name, Status, StartType -AutoSize

invoke-command -computername $servers -FilePath .\my-script.ps1

enter-pssession -computername $targetComputer -UseSSL
Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Service -Name $using:serviceName | Select-Object Name, Status, StartType
} -Credential $cred
#endregion



#region Persistent sessions: reuse a connection for multiple commands
# --- Persistent sessions: reuse a connection for multiple commands ---------
# New-PSSession opens the channel once and keeps it open.
$cred = get-credential 714tech\bob
$session = New-PSSession -ComputerName $targetComputer -Credential $cred
$session

Invoke-Command -Session $session -ScriptBlock { Get-Process | Select-Object -First 3 }
Invoke-Command -Session $session -ScriptBlock { Get-Service | Where-Object Status -eq 'Stopped' | Select-Object -First 5 }

# The big win: state persists between calls on the same session.
Invoke-Command -Session $session -ScriptBlock { $auditStamp = Get-Date }
Invoke-Command -Session $session -ScriptBlock { "Session opened at $auditStamp" }

# Sessions work as a fan-out too - one per machine, all reusable:
$labSessions = New-PSSession -ComputerName $servers -Credential $cred
$labSessions | Format-Table Id, ComputerName, State, Availability -AutoSize

Invoke-Command -Session $labSessions -ScriptBlock {
    [PSCustomObject]@{
        FreeSpaceGB = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
        PSVersion   = $PSVersionTable.PSVersion.ToString()
    }
} | Format-Table PSComputerName, FreeSpaceGB, PSVersion -AutoSize

# Copying files over an existing session (PS 5.0+) - no SMB share needed:
Copy-Item -Path 'C:\Scripts\TMWorkshop26\service.txt' -Destination 'C:\Temp\' -ToSession $session

foreach ($s in $servers) {
    copy-item c:\scripts\drivers\lexmark.inf -Destination \\$s\drivers
}

Copy-Item -Path 'C:\Scripts\TMWorkshop26\service.txt' -Destination 'C:\Temp\' -ToSession $labSessions

# Always clean up - open sessions hold memory on the remote box.
Remove-PSSession -Session $session
Remove-PSSession -Session $labSessions
Get-PSSession   # should now be empty

#endregion

#region CIM sessions: a lighter-weight alternative for WMI/CIM queries
# --- CIM sessions: a lighter-weight alternative for WMI/CIM queries --------
$cimSession = New-CimSession -ComputerName $servers -Credential $cred
$cimSession | Format-Table Id, ComputerName, Protocol -AutoSize

get-ciminstance -ComputerName srv01, srv02, dc01 -ClassName Win32_LogicalDisk -Filter 'DriveType = 3'

Get-CimInstance -CimSession $cimSession -ClassName Win32_LogicalDisk -Filter 'DriveType = 3' |
Select-Object PSComputerName, DeviceID,
@{ Name = 'SizeGB'; Expression = { [math]::Round($_.Size / 1GB, 1) } },
@{ Name = 'FreeGB'; Expression = { [math]::Round($_.FreeSpace / 1GB, 1) } },
@{ Name = 'PercentFree'; Expression = { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) } } |
Sort-Object PercentFree |
Format-Table -AutoSize

Get-CimInstance -CimSession $cimSession -ClassName Win32_ComputerSystem |
Select-Object PSComputerName, Manufacturer, Model, NumberOfLogicalProcessors,
@{ Name = 'RAMGB'; Expression = { [math]::Round($_.TotalPhysicalMemory / 1GB, 0) } } |
Format-Table -AutoSize

Remove-CimSession -CimSession $cimSession

#endregion

#region PowerShell 7: remoting over SSH instead of WinRM
# --- PowerShell 7: remoting over SSH instead of WinRM ----------------------
# PowerShell 7 can tunnel remoting over SSH instead of WinRM. Same cmdlets,
# different transport - you swap -ComputerName for -HostName.
#
# Why you would care:
#  - Works to Linux and macOS, not just Windows.
#  - No WinRM, no TrustedHosts, no domain membership, no Kerberos required.
#  - Key-based auth means genuinely passwordless automation.
# What you give up:
#  - No JEA, no disconnected sessions, no -Credential (SSH handles auth).
#  - No implicit second-hop delegation.

# This region needs PowerShell 7 - check before demoing:
$PSVersionTable.PSVersion

# SETUP on each target (one time, elevated):
#   1. Install the OpenSSH Server optional feature:
#        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
#        Start-Service sshd
#        Set-Service -Name sshd -StartupType Automatic
#   2. Register PowerShell 7 as an SSH subsystem. Edit C:\ProgramData\ssh\sshd_config
#      and add this line (note the -nologo, and forward slashes in the path):
#        Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -nologo
#      'progra~1' is the 8.3 short name - sshd_config does not tolerate the
#      space in "Program Files". This is the #1 thing people get wrong.
#   3. Restart-Service sshd

# Verify the SSH listener is up on the targets (WinRM's Test-WSMan won't help here):

$servers = @('SRV01', 'DC01')
foreach ($server in $servers) {
    $tcp = Test-NetConnection -ComputerName $server -Port 22 -WarningAction SilentlyContinue
    [PSCustomObject]@{
        ComputerName = $server
        SSHPort22    = $tcp.TcpTestSucceeded
    }
}

enter-pssession -hostname $targetComputer -UserName 714tech\bob

invoke-command -HostName $servers -UserName bob@714tech -ScriptBlock { hostname }
# One-off command over SSH - note -HostName and -UserName, not -ComputerName:
Invoke-Command -HostName $targetComputer -UserName 'labadmin' -ScriptBlock {
    [PSCustomObject]@{
        Host      = [System.Net.Dns]::GetHostName()
        PSVersion = $PSVersionTable.PSVersion.ToString()
        Edition   = $PSVersionTable.PSEdition
        Transport = 'SSH'
    }
}

# Fan-out over SSH works the same way:
Invoke-Command -HostName $servers -UserName 'labadmin' -ScriptBlock {
    (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
}

# Persistent SSH sessions:
$sshSession = New-PSSession -HostName $targetComputer -UserName 'labadmin'
$sshSession | Format-Table Id, ComputerName, Transport, State -AutoSize

Invoke-Command -Session $sshSession -ScriptBlock { Get-Service -Name sshd }
Remove-PSSession -Session $sshSession

# Interactive over SSH - run by hand, it takes the prompt:
#   Enter-PSSession -HostName SRV01 -UserName labadmin
#   Exit-PSSession

# Key-based auth is the point of all this. Once your public key is in the
# target's authorized_keys, no password prompt appears at all:
#   ssh-keygen -t ed25519
#   # copy the contents of ~\.ssh\id_ed25519.pub to the target's
#   # C:\Users\labadmin\.ssh\authorized_keys
#   # (for members of Administrators the file is instead
#   #  C:\ProgramData\ssh\administrators_authorized_keys)

# Non-standard port or an explicit key file:
# Invoke-Command -HostName SRV02 -UserName labadmin -Port 2222 `
#     -KeyFilePath "$HOME\.ssh\id_ed25519" -ScriptBlock { hostname }

# You can also define the connection as a hashtable - useful for mixed labs:
$sshTarget = @{ HostName = 'SRV02'; UserName = 'labadmin' }
Invoke-Command @sshTarget -ScriptBlock { $PSVersionTable.PSVersion }

#endregion

#region Putting it together: a small multi-server health report
# --- Putting it together: a small multi-server health report ---------------
$healthReport = Invoke-Command -ComputerName $servers -ScriptBlock {
    $os = Get-CimInstance Win32_OperatingSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'"

    [PSCustomObject]@{
        UptimeDays  = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 1)
        FreeRAMGB   = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        FreeDiskGB  = [math]::Round($disk.FreeSpace / 1GB, 1)
        StoppedAuto = (Get-Service | Where-Object { $_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic' }).Count
    }
} -ErrorAction SilentlyContinue |
Select-Object @{ Name = 'ComputerName'; Expression = { $_.PSComputerName } },
UptimeDays, FreeRAMGB, FreeDiskGB, StoppedAuto

$healthReport | Format-Table -AutoSize
$healthReport | Export-Csv -Path "$PSScriptRoot\health-report.csv" -NoTypeInformation

# Talking points:
#  - Invoke-Command runs and returns; New-PSSession keeps a channel open.
#  - Everything crossing the wire is serialized - you get property bags back,
#    not live objects, so methods like .Kill() are gone. Do the work remotely.
#  - WinRM uses HTTP 5985 / HTTPS 5986; SSH remoting uses port 22 instead.
#  - Fan-out is parallel and throttled at 32 machines by default (-ThrottleLimit).
#  - WinRM for domain-joined Windows fleets; SSH for cross-platform, workgroup,
#    or anywhere you would rather manage keys than Kerberos.
#endregion
