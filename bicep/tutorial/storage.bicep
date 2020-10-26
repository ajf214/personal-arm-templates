param namePrefix string = 'alex'
param location string = resourceGroup().location
var storageSku = 'Standard_LRS'

resource stg 'microsoft.storage/storageAccounts@2019-06-01' = {
  name: '${namePrefix}${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'Storage'
  sku: {
    name: storageSku
  }
}

output stgId string = stg.id
output blobEndpoint string = stg.properties.primaryEndpoints.blob
