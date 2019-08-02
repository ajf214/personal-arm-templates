param(
    [Parameter(Mandatory=$true)]$spnPass
)

$spnId = "30cabdde-8d15-4cf5-b69b-9efcd2437956" # bp-contributor SPN
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$bpName = "foundation-with-pci"
$mgId = "2cc4a1e3-2d9e-4d60-9f42-43da6960ac91"
$subId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2"
$userAssignedPrincipalId = "/subscriptions/e4272367-5645-4c4e-9c67-3b74b59a6982/resourceGroups/Contoso/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alex-test-identity"

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$bpPath = "$scriptDir\foundation-with-pci"


Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

# import a blueprint should succeed
Import-AzBlueprintWithArtifact -Name $bpName -InputPath $bpPath -ManagementGroupId $mgId

# version a bluerint should succeed
Write-Host "Importing blueprint..."
$bp = Get-AzBlueprint -Name $bpName -ManagementGroupId $mgId
Write-Host "Publishing new version..."
Publish-AzBlueprint -Blueprint $bp -Version Get-Random

# assign a blueprint should fail
Write-Host "Starting assignment creation..."
$bpPublished = Get-AzBlueprint -ManagementGroupId $mgId -Name $bpName -LatestPublished
#endregion

#region CreateAssignment
# Create the hash table for Parameters
$bpParameters = @{ deployAuditingonSQLservers_storageAccountsResourceGroup="Diag-001";}

# Create the hash table for ResourceGroupParameters
$bpRGParameters = @{Diagnostics=@{name='Diag-001'; location='westus'}}

# Create the new blueprint assignment
New-AzBlueprintAssignment -Name 'my-blueprint-assignment2' -Blueprint $bpPublished -SubscriptionId $subId -Location 'westus' -Parameter $bpParameters -ResourceGroupParameter $bpRGParameters -UserAssignedIdentity $userAssignedPrincipalId
# endregion CreateAssignment
