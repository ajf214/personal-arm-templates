<#
param(
    [Parameter(Mandatory=$true)]$spnPass
)
#>

# This SPN only has the custom 'Blueprint Assigner' role, which should only be able to assign existing roles
# It also has Reader access to the parent MG where the blueprint object lives

# $spnId = "da2625e3-d0dc-4f81-a3db-6c98a98d9210"
# $tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$mgId = "ContosoRoot"
$blueprintName = "Boilerplate"
$subId = "0ba674a6-9fde-43b4-8370-a7e16fdf0641"
$paramsFile = "params.json"
$location = "westus2"

<#
Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId
#>

Write-Host "See which sub we've got with this SPN"
Get-AzContext

# I gave Reader access to this identity to my BlueprintAssigner SPN to start...
$userAssignedPrincipalId = "/subscriptions/e4272367-5645-4c4e-9c67-3b74b59a6982/resourceGroups/Contoso/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alex-test-identity"

#region GetBlueprint
# Get version '1.1' of the blueprint definition in the specified subscription
$bpDefinition = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName -LatestPublished
#endregion

#region CreateAssignment

<#
# Create the hash table for Parameters
$principal = 'd3e063f7-09cb-4526-9021-4759a7ba179c' # specific to tenant
$bpParameters = @{ principalIds=$principal; genericBlueprintParameter='test'}

# Create the hash table for ResourceGroupParameters
$bpRGParameters = @{SingleRg=@{name='test_0123';location='westus2'}}
#>

# get the parent path so we can more easily use relative paths
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$json = Get-Content -Raw -Path "$scriptDir\$paramsFile" | ConvertFrom-Json -Depth 10 # -AsHashtable
$params = $json."parameters"
$rgParams = $json."resourceGroups"
# Write-Host $json

<#
$paramsData = Import-PowerShellDataFile "$scriptDir\$paramsFile"
$params = $paramsData.parameters
$rgParams = $paramsData.resourceGroups
#>

Write-Host $params
Write-Host $rgParams

Write-Host $json.parameters.principalIds

<#
# Create the new blueprint assignment
New-AzBlueprintAssignment -Name 'my-blueprint-assignment' -Blueprint $bpDefinition -SubscriptionId $subId -Location $location -Parameter $params -ResourceGroupParameter $rgParams -UserAssignedIdentity $userAssignedPrincipalId
#endregion CreateAssignment
#>