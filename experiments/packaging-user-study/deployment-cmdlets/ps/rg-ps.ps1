# Deployment cmdlet consolidation

# Option 1
New-AzDeployment -ResourceGroupName "rg-001" -TemplateFile ".\azureDeploy.json" -TemplateParameterFile ".\params.json"

# Option 2
New-AzDeployment -ScopeType "ResourceGroup" -ResourceGroupName "rg-001" -TemplateFile ".\azureDeploy.json" -TemplateParameterFile ".\params.json"
