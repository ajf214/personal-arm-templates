/*
DEMO FLOW

- Show "complex" website.bicep to show what we want to deploy
- Show simple main.bicep with targetScope set to subscription
- Declare RG resource and show off intellisense
- Declare module and show intellisense
- Start deployment directly with Az CLI

*/

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: 'demo-rg'
  location: 'eastus'
}

module siteDeploy 'website.bicep' = {
  name: 'siteDeploy'
  scope: resourceGroup(rg.name)
  params: {
    acrName: 'myAcr'
    dockerImageAndTag: 'app/frontend:latest'
    dockerUsername: 'dockerAdmin'
  }
}