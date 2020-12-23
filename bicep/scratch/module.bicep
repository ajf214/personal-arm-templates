
// resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
//   name: uniqueString(resourceGroup().id)
//   kind: 'StorageV2'
//   location: 'eastus'
//   sku: {
//     name: 'Standard_LRS'
//   }
// }