param tsSub string = subscription().subscriptionId
param tsRg string = resourceGroup().location
param tsName string = 'ignite20'
param tsVersion string = '0.1'

var tsId = resourceId(tsSub, tsRg, 'microsoft.resources/templateSpecs/versions', tsName, tsVersion)
resource tsDeploy 'microsoft.resources/deployments@2020-06-01' = {
  name: 'tsdeploy'
  properties: {
    mode: 'Incremental'
    templateLink: {
      id: tsId
    }
  }
}