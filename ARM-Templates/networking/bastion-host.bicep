param location string
param resourceGroup string
param bastionHostName string
param subnetId string
param publicIpAddressName string
param vnetName string

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {}
}

resource my_vnet 'Microsoft.Network/virtualNetworks@2019-02-01' = {
  name: 'my-vnet'
  location: location
  properties: {
    subnets: [
      {
        name: 'AzureBastionSubnet'
        id: '/subscriptions/66ee64da-2532-4d9a-a36b-d745327d20d9/resourceGroups/Application-resource-group/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
    ]
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
  tags: {}
}


resource bastionHostName_resource 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: resourceId(resourceGroup, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
          }
        }
      }
    ]
  }
  dependsOn: [
    resourceId(resourceGroup, 'Microsoft.Network/publicIpAddresses', publicIpAddressName) // should be: publicIpAddressName_resource
    resourceId(resourceGroup, 'Microsoft.Network/virtualNetworks', vnetName) // should be my_vnet
  ]
}