# OPTION 1
az deployment create --management-group-id "5d7c4400-6274-4d13-8432-4c1cdefce54f" --template-file ".\azureDeploy.json"

# OPTION 2
az deployment create --scope-type "managementGroup" --management-group-id "5d7c4400-6274-4d13-8432-4c1cdefce54f" --template-file ".\azureDeploy.json"