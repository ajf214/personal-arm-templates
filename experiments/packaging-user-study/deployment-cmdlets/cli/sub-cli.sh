# OPTION 1
az deployment create --subscription-id "8a8f7ed4-00f7-485c-8d93-0d919047723a" --template-file ".\azureDeploy.json"

# OPTION 2
az deployment create --scope-type "subscription" --subscription-id "8a8f7ed4-00f7-485c-8d93-0d919047723a" --template-file ".\azureDeploy.json"