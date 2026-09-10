function Get-DiskSpaceReport {
    <#
    .SYNOPSIS
        Returns free/used space for all local fixed drives.
    .EXAMPLE
        Get-DiskSpaceReport
    #>
    [CmdletBinding()]
    param()

    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        [PSCustomObject]@{
            Drive       = $_.DeviceID
            FreeGB      = [math]::Round($_.FreeSpace / 1GB, 2)
            SizeGB      = [math]::Round($_.Size / 1GB, 2)
            PercentFree = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
        }
    }
}
