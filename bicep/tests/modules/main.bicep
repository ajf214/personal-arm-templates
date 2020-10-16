param location string = 'eastus'
var stgKind = 'Storage'

resource stg 'microsoft.storage/storageAccounts@2019-06-01' = {
  name: '!@mystorage001fawe awefawefaw afwe wef aw'
  location: location
  kind: stgKind
  sku: {
    name: 'Standard_LRS'
  }
}

module networking './network.bicep' = {
  name: 'networking'
  params: {
    test: 'value'
  }
}

output vnetId string = networking.outputs.outTest
output blobUri string = stg.properties.primaryEndpoints.blob