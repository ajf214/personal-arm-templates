targetScope = 'resourceGroup'

param name string = ''
param vnet_1_name string = ''
param vnet_2_name string = ''
param remote_address_prefix string = ''
param primaryRegion string = ''
param secondaryRegion string = ''

// resource vnet1_to_vnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
//   name: name
//   properties: {
//     peeringState: 'Connected'
//     remoteVirtualNetwork: {
//       id: vnet_2_name
//     }
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteAddressSpace: {
//       addressPrefixes: [
//         remote_address_prefix
//       ]
//     }
//   }
// }

output name string = name
