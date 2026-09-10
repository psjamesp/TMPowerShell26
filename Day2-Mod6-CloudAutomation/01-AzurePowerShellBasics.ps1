<#
.SYNOPSIS
    Module 6 Demo: Azure PowerShell Integration

.DESCRIPTION
    Introduces the Az module: installation, authentication, subscription
    context, and basic resource queries/management. Commands that make
    changes are commented out by default so the demo is safe to run
    against a shared or trial subscription.

.NOTES
    Workshop Day 2 - Module 6: Cloud Integration & Advanced Automation
    PREREQUISITE: Install-Module -Name Az -Scope CurrentUser -Repository PSGallery
    Students need an Azure account (free tier is sufficient) for hands-on parts.

#>

#region Installing and importing the Az module
   Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
   Import-Module Az.Accounts, Az.Resources, Az.Compute

# Talking point: the old AzureRM module is deprecated - always use Az for new work.
#endregion

#region Authenticating
   Connect-AzAccount                        # interactive browser sign-in
   Connect-AzAccount -Identity              # from a Managed Identity (Azure VM/Automation)
   Connect-AzAccount -ServicePrincipal -Credential $cred -TenantId $tenantId   # unattended/CI

#endregion

#region Subscription context
 Get-AzSubscription
Set-AzContext -SubscriptionId '7928c129-07bf-46cf-ba05-660d88dd4a50'
 Get-AzContext | select *
#endregion

#region Reading resources (safe to run live)
 Get-AzResourceGroup | Select-Object ResourceGroupName, Location
 Get-AzVM | Select-Object Name, ResourceGroupName, PowerState
 Get-AzStorageAccount | Select-Object StorageAccountName, ResourceGroupName, Sku
#endregion

#region Creating resources (talk through, don't run against shared subs)
 New-AzResourceGroup -Name "rg-workshop-demo" -Location "eastus"
#
 New-AzVM `
    -ResourceGroupName "rg-workshop-demo" `
     -Name "vm-demo01" `
     -Location "eastus" `
     -Credential (Get-Credential) `
     -Size "Standard_B2s"
#endregion

#region Managing VM power state (safe pattern for a lab VM)
 Stop-AzVM -ResourceGroupName "rg-workshop-demo" -Name "vm-demo01" -Force
 Start-AzVM -ResourceGroupName "rg-workshop-demo" -Name "vm-demo01"
#endregion

#region Tagging for governance (a very common enterprise ask)
 $tags = @{ Environment = 'Workshop'; Owner = 'ITTraining'; AutoShutdown = 'true' }
 Update-AzTag -ResourceId (Get-AzVM -Name "vm-demo01" -ResourceGroupName "rg-workshop-demo").Id -Tag $tags -Operation Merge

#endregion


Install-Module Microsoft.Graph -Scope allusers -force
import-module Microsoft.Graph

connect-mggraph -scopes "User.Read.All"

get-mguser

get-mguser "james@714tech.io" | select Id

Add-Mguser .\credential.json -PasswordProfile .\password.json -DisplayName "James Smith" -UserPrincipalName "