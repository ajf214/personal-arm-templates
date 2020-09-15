param storageLocation string 

resource stg 'Microsoft.Storage/storageAccounts@2016-01-01' = {
  name: uniqueString(resourceGroup().id)
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  location: storageLocation
  tags: {
  }
  properties: {
  }
}

