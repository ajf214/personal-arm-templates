
# OPTION 1
az deployment create --resource-group "rg-001" --template-file ".\azureDeploy.json"

# OPTION 2
az deployment create --scope-type "resourceGroup" --resource-group "rg-001" --template-file ".\azureDeploy.json"