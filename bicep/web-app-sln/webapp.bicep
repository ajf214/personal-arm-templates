param name string
param location string

param acrName string
param dockerUsername string
param dockerPassword string
param dockerImageAndTag string

resource site 'microsoft.web/sites@2018-11-01' = {
  name: '${name}-site'
  location: location
  properties: {
    name: '${name}-site'
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io' // 'https://almancontainerregistry.azurecr.io' 
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerUsername // params('dockerUsername')
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: false
        }
      ]
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${dockerImageAndTag}'
    }
    serverFarmId: farm.id // [resourceId('Microsoft.Web/serverFarms', parameter('myServerFarmName'))]
  }
}

resource farm 'microsoft.web/serverFarms@2020-06-01' = {
  name: name
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux' // if kind=app -> windows
  properties: {
    name: name
    workerSize: 0
    workerSizeId: 0
    numberOfWorkers: 1
    reserved: true // true does not get passed through, but "true" does...
  }
}

output websiteId string = site.id

