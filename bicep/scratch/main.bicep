targetScope = 'subscription'

param rgName string
param location string = deployment().location

param groupOwnerId string

var ownerRole = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

resource rgOwner 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: '${guid(rg.name, 'owner')}'
  scope: rg
  properties: {
    roleDefinitionId: ownerRole
    principalId: groupOwnerId
    principalType: 'Group'
  }
}