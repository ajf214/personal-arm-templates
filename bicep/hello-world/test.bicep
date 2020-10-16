param storageName string
var location = 'eastus'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: 'test'
    location: 'eastus'
    sku: {
        name: 'Standard_LRS'
    }
    kind: 'StorageV2'
}

resource stg2 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: 'test'
    location: 'eastus'
    sku: {
        name: 'Standard_LRS'
    }
    kind: 'StorageV2'
    properties: {
      accessTier: 'hot'
    }
}

output stgId string = 'my output' // stg.resourceId

