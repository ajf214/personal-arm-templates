param(
    [Parameter(Mandatory=$true)]$spnPass
)

$spnId = "8c3aedd5-2213-4fc7-9514-e5862895b341" # bp-operator SPN
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"

Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

# Get version '1.1' of the blueprint definition in the specified subscription
Write-Host "Get blueprint at parent MG"
Get-AzBlueprint -ManagementGroupId "2cc4a1e3-2d9e-4d60-9f42-43da6960ac91" -Name "foundation-with-pci" -LatestPublished

Write-Host "Get blueprint at random RG"
Get-AzBlueprint -ManagementGroupId "ContosoRoot" -Name "AppNetwork" -LatestPublished