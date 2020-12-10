resource va9_rt_1 'Microsoft.Network/routeTables@2019-09-01' = {
  name: 'va9-rt-1'
  location: 'eastus'
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}

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
        name: 'Production_PublicOnlySubnet_0'
        properties: {
          addressPrefix: '10.114.0.0/23'
          networkSecurityGroup: {
            id: PublicOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_PublicWANSubnet_0'
        properties: {
          addressPrefix: '10.114.2.0/23'
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_PrivateWANSubnet_0'
        properties: {
          addressPrefix: '10.114.8.0/21'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_PublicOnlySubnet_1'
        properties: {
          addressPrefix: '10.114.16.0/23'
          networkSecurityGroup: {
            id: PublicOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_PublicWANSubnet_1'
        properties: {
          addressPrefix: '10.114.18.0/23'
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_PrivateWANSubnet_1'
        properties: {
          addressPrefix: '10.114.24.0/21'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Staging_PublicOnlySubnet_0'
        properties: {
          addressPrefix: '10.114.128.0/25'
          networkSecurityGroup: {
            id: PublicOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Staging_PublicWANSubnet_0'
        properties: {
          addressPrefix: '10.114.128.128/25'
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Staging_PrivateWANSubnet_0'
        properties: {
          addressPrefix: '10.114.130.0/23'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Staging_PublicOnlySubnet_1'
        properties: {
          addressPrefix: '10.114.132.0/25'
          networkSecurityGroup: {
            id: PublicOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Staging_PublicWANSubnet_1'
        properties: {
          addressPrefix: '10.114.132.128/25'
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Staging_PrivateWANSubnet_1'
        properties: {
          addressPrefix: '10.114.134.0/23'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'SharedServices_PublicOnlySubnet_0'
        properties: {
          addressPrefix: '10.114.160.0/25'
          networkSecurityGroup: {
            id: PublicOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'SharedServices_PublicWANSubnet_0'
        properties: {
          addressPrefix: '10.114.160.128/25'
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'SharedServices_PrivateWANSubnet_0'
        properties: {
          addressPrefix: '10.114.162.0/23'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'SharedServices_PublicOnlySubnet_1'
        properties: {
          addressPrefix: '10.114.164.0/25'
          networkSecurityGroup: {
            id: PublicOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'SharedServices_PublicWANSubnet_1'
        properties: {
          addressPrefix: '10.114.164.128/25'
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'SharedServices_PrivateWANSubnet_1'
        properties: {
          addressPrefix: '10.114.166.0/23'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AKSDataPipeIntegration_PrivateWANSubnet_0'
        properties: {
          addressPrefix: '10.114.248.0/22'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AKSGeneralUseProduction_PrivateWANSubnet_0'
        properties: {
          addressPrefix: '10.114.244.0/22'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          routeTable: {
            id: va9_rt_1.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.114.255.224/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'LoadBalancerSubnet'
        properties: {
          addressPrefix: '10.114.255.128/26'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_Public_LoadBalancerSubnet_UI_Proxy'
        properties: {
          addressPrefix: '10.114.252.0/28'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_Public_LoadBalancerSubnet_Tracking'
        properties: {
          addressPrefix: '10.114.252.16/28'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_Public_LoadBalancerSubnet_Jira'
        properties: {
          addressPrefix: '10.114.252.32/28'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_Public_LoadBalancerSubnet'
        properties: {
          addressPrefix: '10.114.255.0/26'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Production_Private_LoadBalancerSubnet'
        properties: {
          addressPrefix: '10.114.255.64/26'
          networkSecurityGroup: {
            id: PrivateOnly.id
          }
          serviceEndpoints: []
          delegations: []
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

resource PublicOnly 'Microsoft.Network/networkSecurityGroups@2019-09-01' = {
  name: 'PublicOnly'
  location: 'eastus'
  properties: {
    securityRules: [
      {
        name: 'BlockInternal'
        properties: {
          description: 'Block Internal Access.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowPublic'
        properties: {
          description: 'Allow Public Access.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4001
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource PrivateOnly 'Microsoft.Network/networkSecurityGroups@2019-09-01' = {
  name: 'PrivateOnly'
  location: 'eastus'
  properties: {
    securityRules: [
      {
        name: 'AllowInternalInbound'
        properties: {
          description: 'Allow Outbound Access for Private subnets.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowInternalOutbound'
        properties: {
          description: 'Allow Outbound Access for Private subnets.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4000
          direction: 'Outbound'
        }
      }
    ]
  }
}

output Production_PublicOnlySubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Production_PublicOnlySubnet_0')
output Production_PublicWANSubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Production_PublicWANSubnet_0')
output Production_PrivateWANSubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Production_PrivateWANSubnet_0')
output Production_PublicOnlySubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Production_PublicOnlySubnet_1')
output Production_PublicWANSubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Production_PublicWANSubnet_1')
output Production_PrivateWANSubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Production_PrivateWANSubnet_1')
output Staging_PublicOnlySubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Staging_PublicOnlySubnet_0')
output Staging_PublicWANSubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Staging_PublicWANSubnet_0')
output Staging_PrivateWANSubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Staging_PrivateWANSubnet_0')
output Staging_PublicOnlySubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Staging_PublicOnlySubnet_1')
output Staging_PublicWANSubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Staging_PublicWANSubnet_1')
output Staging_PrivateWANSubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'Staging_PrivateWANSubnet_1')
output SharedServices_PublicOnlySubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'SharedServices_PublicOnlySubnet_0')
output SharedServices_PublicWANSubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'SharedServices_PublicWANSubnet_0')
output SharedServices_PrivateWANSubnet_0_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'SharedServices_PrivateWANSubnet_0')
output SharedServices_PublicOnlySubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'SharedServices_PublicOnlySubnet_1')
output SharedServices_PublicWANSubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'SharedServices_PublicWANSubnet_1')
output SharedServices_PrivateWANSubnet_1_resourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'va9-vnet', 'SharedServices_PrivateWANSubnet_1')