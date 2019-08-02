param(
    [Parameter(Mandatory=$true)]$spnPass
)


# This SPN only has the custom 'Blueprint Assigner' role, which should only be able to assign existing roles
# It also has Reader access to the parent MG where the blueprint object lives

$spnId = "8c3aedd5-2213-4fc7-9514-e5862895b341" # bp-operator SPN
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$mgId = "2cc4a1e3-2d9e-4d60-9f42-43da6960ac91" # azure-blueprints-pipeline
$blueprintName = "foundation-with-pci"
$subId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # Contoso IT - SH360 - Prod


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
$bpParameters = @{ deployAuditingonSQLservers_storageAccountsResourceGroup="Diag-001";}

# Create the hash table for ResourceGroupParameters
$bpRGParameters = @{Diagnostics=@{name='Diag-001'; location='westus'}}

# Create the new blueprint assignment
New-AzBlueprintAssignment -Name 'my-blueprint-assignment' -Blueprint $bpDefinition -SubscriptionId $subId -Location 'westus' -Parameter $bpParameters -ResourceGroupParameter $bpRGParameters -UserAssignedIdentity $userAssignedPrincipalId
#endregion CreateAssignment