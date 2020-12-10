resource va9_vnet 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: 'va9-vnet'
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.114.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aaa'
        properties: {
          addressPrefix: '10.114.255.64/26'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'bbb' // swap me with subnet 'ccc'
        properties: {
          addressPrefix: '10.114.8.0/21'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'ccc'
        properties: {
          addressPrefix: '10.114.0.0/23'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'ddd'
        properties: {
          addressPrefix: '10.114.2.0/23'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'eee'
        properties: {
          addressPrefix: '10.114.8.0/21'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
    enableVmProtection: false
  }
}