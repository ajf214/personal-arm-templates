param optionalSubnets array = []

@description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param podCidr string = ''

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param serviceCidr string = ''

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param dnsServiceIP string = ''

@description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param dockerBridgeCidr string = ''

var resgpguid = substring(replace(guid(resourceGroup().id), '-', ''), 0, 4)
var uniqueResourceName_var = 'aksagic${resgpguid}'
var location = resourceGroup().location
var managedRgForCluster = '${resourceGroup().name}-aks'
var vnetName_var = '${uniqueResourceName_var}-vnet'
var dnsprefix = toLower(clusterName_var)
var defaultSubnetPrefix = '10.0.1.0/24'
var aksSubnetPrefix = '10.0.2.0/24'
var clusterName_var = '${uniqueResourceName_var}-aks'
var aksSubnetName = 'aks'
var aksSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName_var, aksSubnetName)
var standardSubnets = [
  'default'
  'aks'
]
var deploySubnets = concat(standardSubnets, optionalSubnets)
var subnets = [
  {
    name: 'default'
    addressPrefix: defaultSubnetPrefix
  }
  {
    name: 'aks'
    addressPrefix: aksSubnetPrefix
  }
]

resource la 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: uniqueResourceName_var
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource vnetName 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName_var
  location: location
  tags: {
    displayName: vnetName_var
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties:{
        addressPrefix: subnet.addressPrefix
        privateLinkServiceNetworkPolicies: subnet.PrivateLinkServiceNetworkPolicies
      }
    }]
  }
}

resource clusterName 'Microsoft.ContainerService/managedClusters@2020-12-01' = {
  name: clusterName_var
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsprefix
    nodeResourceGroup: managedRgForCluster
    agentPoolProfiles: [
      {
        name: 'system'
        count: 3
        enableAutoScaling: true
        maxCount: 10
        minCount: 3
        vmSize: 'Standard_DS3_v2'
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        vnetSubnetID: aksSubnetId
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: la.id
        }
      }
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      podCidr: podCidr
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
      loadBalancerSku: 'standard'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
  }
}

module ClusterRoleAssignmentDeployment './cluster-role-assign.bicep' = {
  name: 'ClusterRoleAssignmentDeployment'
  scope: resourceGroup(managedRgForCluster)
  params: {
    clustername: clusterName_var
    aksResourceGroup: resourceGroup().name
  }
  dependsOn: [
    clusterName
  ]
}
