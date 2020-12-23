targetScope = 'resourceGroup'

module mod './module.bicep' = {
  name: 'test'
  scope: resourceGroup('<SUB-GUID-GOES-HERE>', '<RG-NAME-GOES-HERE')
}