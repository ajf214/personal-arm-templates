param storageName string
var location = 'eastus'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageName
    location: location
    sku: {
        name: 'Standard_LRS'
    }
    kind: 'StorageV2'
}

output stgId string = stg.resourceId
