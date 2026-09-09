<#
.SYNOPSIS
    EXERCISE 4 - Multi-Server Remote Service Check

.INSTRUCTIONS
    Using the lab servers provided by your instructor:
      1. Prompt for credentials once with Get-Credential (never hardcode a password)
      2. Use Invoke-Command against ALL target servers at once (pass an array
         to -ComputerName, not a loop) to check Spooler and BITS
      3. Return one object per server/service pair: ComputerName, Service, Status
      4. Handle unreachable servers gracefully (don't let one failure kill the batch)
#>

# TODO 1: $servers = @('<lab-server-1>', '<lab-server-2>')   # from instructor

# TODO 2: $cred = Get-Credential -Message "Lab admin credentials"

# TODO 3: Use Invoke-Command -ComputerName $servers -Credential $cred -ErrorAction SilentlyContinue -ScriptBlock {
#             foreach ($svcName in 'Spooler','BITS') {
#                 $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
#                 [PSCustomObject]@{
#                     ComputerName = $env:COMPUTERNAME
#                     Service      = $svcName
#                     Status       = if ($svc) { $svc.Status } else { 'NotFound' }
#                 }
#             }
#         }

# TODO 4: Pipe the results to Format-Table -AutoSize and eyeball them

# BONUS: Capture unreachable servers with -ErrorVariable and print a warning
#        listing which servers couldn't be reached.
