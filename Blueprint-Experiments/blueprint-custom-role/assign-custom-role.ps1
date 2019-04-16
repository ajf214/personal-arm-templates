param(
    [Parameter(Mandatory=$true)]$spnPass
)

# This SPN only has the custom 'Blueprint Assigner' role, which should only be able to assign existing roles
# It also has Reader access to the parent MG where the blueprint object lives

$spnId = "da2625e3-d0dc-4f81-a3db-6c98a98d9210"
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$mgId = "ContosoRoot"
$blueprintName = "Boilerplate"
$subId = "35ad74f4-0b37-44a7-ba94-91b6ec6026cd"

Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

Write-Host "See which sub we've got with this SPN"
Get-azContext

# I gave Reader access to this identity to my BlueprintAssigner SPN to start...
$userAssignedPrincipalId = "/subscriptions/e4272367-5645-4c4e-9c67-3b74b59a6982/resourceGroups/Contoso/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alex-test-identity"

#region GetBlueprint
# Get version '1.1' of the blueprint definition in the specified subscription
$bpDefinition = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName -LatestPublished
#endregion

#region CreateAssignment
# Create the hash table for Parameters
$principal = 'd3e063f7-09cb-4526-9021-4759a7ba179c' # specific to tenant
$bpParameters = @{ principalIds=$principal; genericBlueprintParameter='test'}

# Create the hash table for ResourceGroupParameters
$bpRGParameters = @{SingleRg=@{name='test_0123';location='westus2'}}

# Create the new blueprint assignment
New-AzBlueprintAssignment -Name 'my-blueprint-assignment' -Blueprint $bpDefinition -SubscriptionId $subId -Location 'westus2' -Parameter $bpParameters -ResourceGroupParameter $bpRGParameters -UserAssignedIdentity $userAssignedPrincipalId
#endregion CreateAssignment