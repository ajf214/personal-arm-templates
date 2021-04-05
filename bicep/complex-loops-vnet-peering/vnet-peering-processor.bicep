/* 

Input:
A VNET object

Output:
N VNET peering resources

*/

param vnet object

module vnetpeerings 'vnet-peer.template.bicep' = [for peer in vnet.peerings: {
  name: 'createPeer-${peer.name}'
  params: {
    name: peer.name
    vnet_1_name: vnet.name
    vnet_2_name: peer.target
    remote_address_prefix: '' // not sure
    primaryRegion: '' // not sure
    secondaryRegion: '' // not sure
  }
}]

output peerNames array = [for (peer, i) in vnet.peerings: vnetpeerings[i].outputs.name]
