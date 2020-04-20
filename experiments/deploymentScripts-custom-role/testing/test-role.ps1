param (
    [Parameter(Mandatory=$true)]$spnPass
)


# This SPN only has the custom 'Blueprint Assigner' role, which should only be able to assign existing roles
# It also has Reader access to the parent MG where the blueprint object lives

$spnId = "ffa87164-a533-43a5-b0ed-44b1ecfe4adb"
$tenantId = "220caee9-352a-4eb3-80eb-cc1dabf7be3c"
# $subId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # Contoso IT - SH360 - Prod

az login --service-principal -u $spnId -p $spnPass --tenant $tenantId
az account show

# create-deployment-script
# run ARM template w/ deploymentScript
$file = 'D:\repos\personal-arm-templates\experiments\deploymentScripts-custom-role\testing\deployment-script-template.json'
az deployment group create -g brittle-hollow -f $file

# clear and log back in to my user
az account clear
az login

