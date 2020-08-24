<<<<<<< HEAD:bicep/hello-world/test.bicep
param storageName string
var location = 'eastus'
=======
parameter storageName string default 'alex'
variable location = 'eastus'
>>>>>>> 559b3ad035c4c1a2e024afce23ddef24031fd1ca:experiments/bicep/test.arm

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
}

output stgId string = 'my output' // stg.resourceId

