param(
    $spnPass
)


# This SPN only has the custom 'Blueprint Assigner' role, which should only be able to assign existing roles
# It also has Reader access to the parent MG where the blueprint object lives

$spnId = "11760b02-0497-4607-89a8-e04fce097c5f" # bp-operator SPN
$spnPass = "95c83865-70f3-4839-bf9d-118d252b2eea"
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
# $subId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # Contoso IT - SH360 - Prod


Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

# create-deployment-script
# run ARM template w/ deploymentScript

Get-AzContext