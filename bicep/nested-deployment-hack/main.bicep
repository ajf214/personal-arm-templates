var test = 'alex'
var schema = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'

resource nested 'microsoft.resources/deployments@2019-10-01' = {
  name: 'nested001'
  properties: {
    mode: 'incremental'
    template: {
      '$schema': schema
      contentVersion: '1.0.0.0'
      resources: [
      ]
      outputs: {
        test: {
          type: 'string'
          value: test
        }
      }
    }
  }
}