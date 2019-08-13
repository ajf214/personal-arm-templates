# Deployment cmdlet consolidation

# Option 1
New-AzDeployment -ManagementGroupId "5d7c4400-6274-4d13-8432-4c1cdefce54f" -TemplateFile ".\azureDeploy.json" -TemplateParameterFile ".\params.json"

# Option 2
New-AzDeployment -ScopeType "ManagementGroup" -ManagementGroupId "5d7c4400-6274-4d13-8432-4c1cdefce54f" -TemplateFile ".\azureDeploy.json" -TemplateParameterFile ".\params.json"
