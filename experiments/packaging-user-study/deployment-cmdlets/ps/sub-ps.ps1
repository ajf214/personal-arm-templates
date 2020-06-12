# Deployment cmdlet consolidation

# Option 1
New-AzDeployment -SubscriptionId "8a8f7ed4-00f7-485c-8d93-0d919047723a" -TemplateFile ".\azureDeploy.json" -TemplateParameterFile ".\params.json"

# Option 2
New-AzDeployment -ScopeType "Subscription" -SubscriptionId "8a8f7ed4-00f7-485c-8d93-0d919047723a" -TemplateFile ".\azureDeploy.json" -TemplateParameterFile ".\params.json"
