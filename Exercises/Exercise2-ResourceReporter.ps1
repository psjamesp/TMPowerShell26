<#
.SYNOPSIS
    EXERCISE 2 - Process/Service Reporter

.INSTRUCTIONS
    Write a function Get-TopResourceConsumers that:
      - Accepts -Type 'Process' or -Type 'Service' (use [ValidateSet])
      - Accepts -Top <int> defaulting to 5
      - For Process: returns top N by CPU descending (Name, CPU, Id)
      - For Service: returns top N Running services (Name, DisplayName, StartType)
    Test it with both parameter values before moving on.
#>

function Get-TopResourceConsumers {
    [CmdletBinding()]
    param(
        # TODO 1: Add a [ValidateSet('Process','Service')] [string]$Type parameter (mandatory)

        # TODO 2: Add an [int]$Top parameter, default 5
    )

    # TODO 3: If $Type is 'Process', get processes, sort by CPU descending,
    #         select the top $Top, and return Name, CPU, Id

    # TODO 4: If $Type is 'Service', get services where Status is 'Running',
    #         select the top $Top, and return Name, DisplayName, StartType
}

# TODO 5: Call your function both ways and eyeball the output:
# Get-TopResourceConsumers -Type Process -Top 5
# Get-TopResourceConsumers -Type Service -Top 5
