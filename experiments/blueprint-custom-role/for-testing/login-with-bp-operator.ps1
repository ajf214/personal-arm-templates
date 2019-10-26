param(
    [Parameter(Mandatory=$true)]$spnPass
)


# This SPN only has the custom 'Blueprint Assigner' role, which should only be able to assign existing roles
# It also has Reader access to the parent MG where the blueprint object lives

$spnId = "8c3aedd5-2213-4fc7-9514-e5862895b341" # bp-operator SPN
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"


Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId


Write-Host "See which sub we've got with this SPN"
Get-azContext