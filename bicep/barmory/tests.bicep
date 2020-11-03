// inventing a keyword called "test"
test serviceFabricAAD = {
  name: 'serviceFabricAAD'
  description: 'Service Fabric clusters should only use Azure Active Directory for client authentication'
  check: {
    resourceType: 'Microsoft.ServiceFabric/clusters'
    path: 'properties.azureActiveDirectory.tenantId'
    hasValue: false
  }
}

var ftpAllowedStates = [
  'FtpsOnly'
  'Disabled'
]

test ApiApp_useFTPS = {
  name: 'ApiApp_UsesFTPS'
  description: 'FTPS only should be required in your API App'
  check: {
    resourceType: 'Microsoft.Web/sites'
    allOf: [
      {
        path: 'kind'
        regex: 'api$'
      }
      {
        resourceType: 'microsoft.web/sites/config'
        allOf: [
          {
            path: 'name'
            equals: 'web'  
          }
          {
            not: {
              path: 'properties.ftpsState'
              in: ftpAllowedStates
            }
          }        
        ]
      }
    ]
  }
}