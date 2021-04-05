resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = [for i in [
  1
  2
  3
  4
]: {
  name: 'myvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }  
  }
}]

