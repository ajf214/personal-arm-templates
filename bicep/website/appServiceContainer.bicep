param name string
param location string

param acrName string
param dockerUsername string
param dockerPassword string
param dockerImageAndTag string

// todo - conditions and loops not implemented yet
param deployFarm bool = true
param sites array {
  default: [
    {
      suffix: 'prod'
    }
    {
      suffix: 'dev'
    }
  ]
}

resource site 'microsoft.web/sites@2020-06-01' = {
  name: '${name}-${sites[0].suffix}'
  location: location
  properties: {
    // name: '${name}-${sites[0].suffix}'
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
          value: 'false' // schema calls for this to be a string
        }
      ]
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${dockerImageAndTag}'
    }
    serverFarmId: farm.id // [resourceId('Microsoft.Web/serverFarms', param('myServerFarmName'))]
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
    targetWorkerSizeId: 0
    targetWorkerCount: 1
    reserved: true
  }
}

output websiteId string = site.id

