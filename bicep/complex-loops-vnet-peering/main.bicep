// deployment command
// az deployment sub create -f .\main.bicep -p .\params.copy.json -l eastus

targetScope = 'subscription'

param vnets_spec array
param rg_name string = 'brittle-hollow'

resource region_rg 'Microsoft.Resources/resourceGroups@2020-06-01' existing = {
  name: rg_name
}

// given a VNET, create N peerings
// must run after both VNETs have been created
module peerProcessor 'vnet-peering-processor.bicep' = [for vnet in vnets_spec: {
  scope: region_rg
  name: 'peerProcessor-${uniqueString(vnet.name)}'
  params: {
    vnet: vnet
  }
  dependsOn: [
    // both vnets probably
  ]
}]

output peerNames array = [for (vnet, i) in vnets_spec: peerProcessor[i].outputs.peerNames]
