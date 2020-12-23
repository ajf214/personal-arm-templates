param namePrefix string
param location string = 'eastus'

resource vnet 'Microsoft.Network/virtualNetworks@2018-07-01' = {
  name: '${namePrefix}-vnet001'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ 
        '10.0.0.0/24'
      ]
    }
    subnets: []
  }
}

module test '../test.bicep' = {}

output vnetId string = vnet.id
