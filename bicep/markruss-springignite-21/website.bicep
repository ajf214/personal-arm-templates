param name string = 'site001'
param location string = resourceGroup().location

param acrName string // 'myAcr'
param dockerUsername string // 'adminUser'
param dockerImageAndTag string // 'app/frontend:latest'
param acrResourceGroup string = resourceGroup().name
param acrSubscription string = subscription().subscriptionId

// reference to already existing ACR resource
resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' existing = {
  name: acrName
  scope: resourceGroup(acrSubscription, acrResourceGroup)
}

var websiteName = '${name}-site'

resource site 'microsoft.web/sites@2020-06-01' = {
  name: websiteName
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: listCredentials(acr.id, acr.apiVersion).passwords[0].value
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${dockerImageAndTag}'
    }
    serverFarmId: farm.id
  }
}

var farmName = '${name}-farm'

resource farm 'microsoft.web/serverFarms@2020-06-01' = {
  name: farmName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    targetWorkerSizeId: 0
    targetWorkerCount: 1
    reserved: true
  }
}

output publicUrl string = site.properties.defaultHostName
output ftpUser string = any(site.properties).ftpUsername // TODO: workaround for missing property definition
