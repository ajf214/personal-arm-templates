param clustername string
param aksResourceGroup string

// reference to aks resource we just created
resource cluster 'Microsoft.ServiceFabric/managedClusters@2021-01-01-preview' existing = {
  name: clustername
  scope: resourceGroup(aksResourceGroup)
}

// role assignment to aksRg
var role1 = subscriptionResourceId('microsoft.authorization/roleDefinitions', 'f1a07417-d97a-45cb-824c-7a7467783830')
var role2 = subscriptionResourceId('microsoft.authorization/roleDefinitions', '9980e02c-c2be-4d73-94e8-173b1dc7cf3c')


resource clusterRole1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('${resourceGroup().id}${clustername}ManagedOperatorResourceGroup')
  // scope: resourceGroup(aksResourceGroup)
  properties: {
    roleDefinitionId: role1
    principalId: cluster.properties.identityProfile.kubeletidentity.objectId
    // scope: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${aksResourceGroup}' - this is implied by the deployment since it is already targeting the current resource
  }
}



// role assignment to aksRg
resource id_clusterName_VMCResourceGroup 'Microsoft.Authorization/roleAssignments@2017-09-01' = {
  name: guid('${resourceGroup().id}${clustername}VMCResourceGroup')
  properties: {
    roleDefinitionId: role2
    principalId: cluster.properties.identityProfile.kubeletidentity.objectId
    // scope: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${aksResourceGroup}'
  }
}
