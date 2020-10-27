param location string = resourceGroup().location
param namePrefix string = 'stg'

param globalRedundancy bool = true

var storageAccountName = '${namePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${stg.name}/default/logs'
}

output storageId string = stg.id // [resourceId('Microsoft.Storage/storageAccounts', parameters('name'))]
output computedStorageName string = stg.name
output blobEndpoint string = stg.properties.primaryEndpoints.blob // [reference()]
