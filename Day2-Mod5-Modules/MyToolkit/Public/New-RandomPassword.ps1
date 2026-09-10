function New-RandomPassword {
    <#
    .SYNOPSIS
        Generates a random password of a given length for lab/demo use.
    .PARAMETER Length
        Length of the generated password. Default 16.
    .EXAMPLE
        New-RandomPassword -Length 20
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(8, 128)]
        [int]$Length = 16
    )

    # Private helper below is not exported - only used internally
    $chars = ConvertTo-CharacterPool
    -join (1..$Length | ForEach-Object { $chars | Get-Random })
}