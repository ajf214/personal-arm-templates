az account clear
az login --service-principal -u "http://alfranTesting" -p "" --tenant "72f988bf-86f1-41af-91ab-2d7cd011db47"

$templateFile = "F:\repos\personal-arm-templates\ARM-Templates\testing\min-ds-permissions-with-obo\main.json"

az deployment group what-if -f $templateFile -g brittle-hollow
az deployment group create -f $templateFile -g brittle-hollow --verbose

az account clear
az login