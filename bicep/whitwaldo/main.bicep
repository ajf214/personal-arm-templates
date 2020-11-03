//Variables
/*
var vmssApiVersion = '2020-06-01' //https://docs.microsoft.com/en-us/rest/api/compute/virtualmachinescalesets
var serviceFabricApiVersion = '2018-02-01' //https://docs.microsoft.com/en-us/rest/api/servicefabric/sfrp-index
var loadBalancerApiVersion = '2020-05-01' //https://docs.microsoft.com/en-us/rest/api/load-balancer/loadbalancers
var virtualNetworkApiVersion = '2020-05-01' //https://docs.microsoft.com/en-us/rest/api/virtualnetwork/virtualnetworks
var storageApiVersion = '2019-06-01' //https://docs.microsoft.com/en-us/rest/api/storagerp/
var publicIpApiVersion = '2020-05-01' //https://docs.microsoft.com/en-us/rest/api/virtualnetwork/publicipaddresses
*/
var environment = 'Production'
var application = clusterName

//General
param location string = 'eastus2'
param clusterName string = 'Empirica'

//Port ranges
param ntApplicationStartPort int = 20000
param ntApplicationEndPort int = 30000
param ntEphemeralStartPort int = 49152
param ntEphemeralEndPort int = 65534
param ntFabricTcpGatewayPort int = 19000
param ntFabricHttpGatewayPort int = 19080

//VNET Subnets
param subnetBackendPrefix string = '10.0.0.0/24'
param subnetBackendName string = 'Backend'
param subnetCollectionPrefix string = '10.0.1.0/24'
param subnetCollectionName string = 'Collection'
param subnetManagementPrefix string = '10.0.2.0/24'
param subnetManagementName string = 'Management'
param subnetWebPrefix string = '10.0.3.0/24'
param subnetWebName string = 'Web'
param subnetAppGatewayPrefix string = '10.0.5.0/24'
param subnetAppGatewayName string = 'ApplicationGateway'
param subnetBuildServerPrefix string = '10.0.99.0/24'
param subnetBuildServerName string = 'BuildServers'
param subnetDatabricksPrivatePrefix string = '10.0.151.0/24'
param subnetDatabricksPrivateName string = 'PrivateDatabricks'
param subnetDatabricksPublicPrefix string = '10.0.150.0/24'
param subnetDatabricksPublicName string = 'PublicDatabricks'
param subnetBoldBiPrefix string = '10.0.15.0/24'
param subnetBoldBiName string = 'BoldBI'

//Virtual network
param virtualNetworkName string = 'VNet'
param virtualNetworkAddressPrefix string = '10.0.0.0/16'
param dnsName string = 'invn'
param nicName string = 'NIC'
param overProvision string = 'false'
resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
    name: virtualNetworkName
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                virtualNetworkAddressPrefix
            ]
        }
        subnets: [
            {
                name: subnetBackendName
                properties: {
                    addressPrefix: subnetBackendPrefix
                }
            }
            {
                name: subnetCollectionName
                properties: {
                    addressPrefix: subnetCollectionPrefix
                }
            }
            {
                name: subnetManagementName
                properties: {
                    addressPrefix: subnetManagementPrefix
                }
            }
            {
                name: subnetWebName
                properties: {
                    addressPrefix: subnetWebPrefix
                }
            }
            {
                name: subnetAppGatewayName
                properties: {
                    addressPrefix: subnetAppGatewayPrefix
                }
            }
            {
                name: subnetBuildServerName
                properties: {
                    addressPrefix: subnetBuildServerPrefix
                }
            }
            {
                name: subnetDatabricksPrivateName
                properties: {
                    addressPrefix: subnetDatabricksPrivatePrefix
                }
            }
            {
                name: subnetDatabricksPublicName
                properties: {
                    addressPrefix: subnetDatabricksPublicPrefix
                }
            }
            {
                name: subnetBoldBiName
                properties: {
                    addressPrefix: subnetBoldBiPrefix
                }
            }
        ]
        tags: { // af - doesn't look like tags are allowed here, I think you want them as a top level property
            'environment': environment
        }
    }
}

//IP Addresses
param publicIpPrefix string = 'pip-invn-'
var pipBackendName = '${publicIpPrefix}backend'
var pipCollectionName = '${publicIpPrefix}collection'
var pipManagementName = '${publicIpPrefix}management'
var pipWebName = '${publicIpPrefix}management'

resource pipBackend 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
    name: pipBackendName
    location: location
    properties: {
        dnsSettings: {
            domainNameLabel: toLower('${dnsName}${nodeTypeBackendName}')
        }
        publicIPAllocationMethod: 'Dynamic'
    }
    tags: {
      environment: environment
    }
}

resource pipCollection 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
    name: pipCollectionName
    location: location
    properties: {
        dnsSettings: {
            domainNameLabel: toLower('${dnsName}${nodeTypeCollectionName}')
        }
        publicIPAllocationMethod: 'Static'
    }
    tags: {
      environment: environment
  }
}

resource pipManagement 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
    name: pipManagementName
    location: location
    properties: {
        dnsSettings: {
            domainNameLabel: toLower('${dnsName}${nodeTypeManagementName}')
        }
        publicIPAllocationMethod: 'Static'
    }
    tags: {
      environment: environment
    } 
}

resource pipWeb 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
    name: pipWebName
    location: location
    properties: {
        dnsSettings: {
            domainNameLabel: toLower('${dnsName}${nodeTypeWebName}')
        }
        publicIPAllocationMethod: 'Static'
    }
    tags: {
      environment: environment
    } 
}

//Load Balancers
var loadBalancerBackendName = toLower('lb-${clusterName}-${nodeTypeBackendName}')
var loadBalancerCollectionName = 'toLower(lb-${clusterName}-${nodeTypeCollectionName})' // todo - match line above
var loadBalancerManagementName = 'toLower(lb-${clusterName}-${nodeTypeManagementName})'// todo - match line above
var loadBalancerWebName = 'toLower(lb-${clusterName}-${nodeTypeWebName})' // todo - match line above
var loadBalancerFrontendIpName = 'LoadBalancerIPConfig'
var loadBalancerBackendAddressPoolName = 'LoadBalancerBackendAddressPool'
var enableFloatingIp = false
var idleTimeoutInMinutes = 5
var tcpRuleName = 'LoadBalancerTCPRule'
var tcpProbeName = 'FabricTcpGatewayProbe'
var httpRuleName = 'LoadBalancerHttpRule'
var httpProbeName = 'FabricHttpGatewayProbe'
var loadBalancerBackendId = resourceId('Microsoft.Network/loadBalancers', loadBalancerBackendName) // af - switched to native bicep code
var loadBalancerCollectionId = resourceId('Microsoft.Network/loadBalancers', loadBalancerCollectionName)
var loadBalancerManagementId = '[resourceId("Microsoft.Network/loadBalancers/${loadBalancerManagementName}")]' // af - this wont' work, need to match the above
var loadBalancerWebId = '[resourceId("Microsoft.Network/loadBalancers/${loadBalancerWebName}")]'

resource lbBackend 'Microsoft.Network/loadBalancers@2020-05-01' = {
    name: loadBalancerBackendName
    location: location
    dependsOn: [
        pipBackend
    ]
    properties: {
        frontendIPConfigurations: [
            {
                name: loadBalancerFrontendIpName
                properties: {
                    publicIPAddress: {
                        id: pipBackend.id
                    }
                }
            }
        ]
        backendAddressPools: [
            {
                name: loadBalancerBackendAddressPoolName
                properties: {}
            }
        ]
        loadBalancingRules: [
            {
                name: tcpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerBackendId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricTcpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerBackendId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricTcpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerBackendId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
            {
                name: httpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerBackendId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricHttpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerBackendId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricHttpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerBackendId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
        ]
        probes: [
            {
                name: tcpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricTcpGatewayPort
                    protocol: 'tcp'
                }
            }
            {
                name: httpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricHttpGatewayPort
                    protocol: 'http'
                }
            }
        ]
        inboundNatPools: [
            {
                name: 'LoadBalancerBEAddressNATPool'
                properties: {
                    backendPort: 3389
                    frontendIpConfiguration: {
                        id: ''
                    }
                    frontendPortRangeStart: 3389
                    frontendPortRangeEnd: 4500
                    protocol: 'tcp'
                }
            }
        ]
        tags: {
            'environment': environment
        }
    }
}

resource lbCollection 'Microsoft.Network/loadBalancers@2020-05-01' = {
    name: loadBalancerCollectionName
    location: location
    dependsOn: [
        pipCollection
    ]
    properties: {
        frontendIPConfigurations: [
            {
                name: loadBalancerFrontendIpName
                properties: {
                    publicIPAddress: {
                        id: pipCollection.id
                    }
                }
            }
        ]
        backendAddressPools: [
            {
                name: loadBalancerBackendAddressPoolName
                properties: {}
            }
        ]
        loadBalancingRules: [
            {
                name: tcpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerCollectionId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricTcpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerCollectionId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricTcpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerCollectionId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
            {
                name: httpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerCollectionId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricHttpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerCollectionId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricHttpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerCollectionId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
        ]
        probes: [
            {
                name: tcpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricTcpGatewayPort
                    protocol: 'tcp'
                }
            }
            {
                name: httpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricHttpGatewayPort
                    protocol: 'http'
                }
            }
        ]
        inboundNatPools: [
            {
                name: 'LoadBalancerBEAddressNATPool'
                properties: {
                    backendPort: 3389
                    frontendIpConfiguration: {
                        id: ''
                    }
                    frontendPortRangeStart: 3389
                    frontendPortRangeEnd: 4500
                    protocol: 'tcp'
                }
            }
        ]
        tags: {
            'environment': environment
        }
    }
}

resource lbManagement 'Microsoft.Network/loadBalancers@2020-05-01' = {
    name: loadBalancerManagementName
    location: location
    dependsOn: [
        pipManagement
    ]
    properties: {
        frontendIPConfigurations: [
            {
                name: loadBalancerFrontendIpName
                properties: {
                    publicIPAddress: {
                        id: pipManagement.id
                    }
                }
            }
        ]
        backendAddressPools: [
            {
                name: loadBalancerBackendAddressPoolName
                properties: {}
            }
        ]
        loadBalancingRules: [
            {
                name: tcpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerManagementId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricTcpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerManagementId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricTcpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerManagementId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
            {
                name: httpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerManagementId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricHttpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerManagementId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricHttpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerManagementId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
        ]
        probes: [
            {
                name: tcpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricTcpGatewayPort
                    protocol: 'tcp'
                }
            }
            {
                name: httpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricHttpGatewayPort
                    protocol: 'http'
                }
            }
        ]
        inboundNatPools: [
            {
                name: 'LoadBalancerBEAddressNATPool'
                properties: {
                    backendPort: 3389
                    frontendIpConfiguration: {
                        id: ''
                    }
                    frontendPortRangeStart: 3389
                    frontendPortRangeEnd: 4500
                    protocol: 'tcp'
                }
            }
        ]
        tags: {
            'environment': environment
        }
    }
}

resource lbWeb 'Microsoft.Network/loadBalancers@2020-05-01' = {
    name: loadBalancerWebName
    location: location
    dependsOn: [
        pipWeb
    ]
    properties: {
        frontendIPConfigurations: [
            {
                name: loadBalancerFrontendIpName
                properties: {
                    publicIPAddress: {
                        id: pipWeb.id
                    }
                }
            }
        ]
        backendAddressPools: [
            {
                name: loadBalancerBackendAddressPoolName
                properties: {}
            }
        ]
        loadBalancingRules: [
            {
                name: tcpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerWebId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricTcpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerWebId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricTcpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerWebId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
            {
                name: httpRuleName
                properties: {
                    backendAddressPool: {
                        id: '${loadBalancerWebId}/backendAddressPool/${loadBalancerBackendAddressPoolName}'
                    }
                    backendPort: ntFabricHttpGatewayPort
                    enableFloatingIP: enableFloatingIp
                    frontendIPConfiguration: {
                        id: '${loadBalancerWebId}/frontendIPConfigurations/${loadBalancerFrontendIpName}'
                    }
                    frontendPort: ntFabricHttpGatewayPort
                    idleTimeoutInMinutes: idleTimeoutInMinutes
                    probe: {
                        id: '${loadBalancerWebId}/probes/${tcpProbeName}'
                    }
                    protocol: 'tcp'
                }
            }
        ]
        probes: [
            {
                name: tcpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricTcpGatewayPort
                    protocol: 'tcp'
                }
            }
            {
                name: httpProbeName
                properties: {
                    intervalInSeconds: 5
                    numberOfProbes: 2
                    port: ntFabricHttpGatewayPort
                    protocol: 'http'
                }
            }
        ]
        inboundNatPools: [
            {
                name: 'LoadBalancerBEAddressNATPool'
                properties: {
                    backendPort: 3389
                    frontendIpConfiguration: {
                        id: ''
                    }
                    frontendPortRangeStart: 3389
                    frontendPortRangeEnd: 4500
                    protocol: 'tcp'
                }
            }
        ]
        tags: {
            'environment': environment
        }
    }
}

//NSGs
var nsgBackendName = 'nsg-backend'
var nsgCollectionName = 'nsg-collection'
var nsgManagementName = 'nsg-management'
var nsgWebName = 'nsg-web'

resource nsgBackend 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
    name: nsgBackendName
    location: location
    properties: {
        securityRules: [
            {
                name: 'allowAppPortHttp'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTP'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '80'
                    direction: 'Inbound'
                    priority: 500
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'   
                }
            }
            {
                name: 'allowAppPortHttps'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTPS'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                    direction: 'Inbound'
                    priority: 510
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork' // there was a typo here
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricCluster'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '1025-1027'
                    direction: 'Inbound'
                    priority: 520
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricEphemeral'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '49152-65534'
                    direction: 'Inbound'
                    priority: 530
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricSMB'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '445'
                    direction: 'Inbound'
                    priority: 540
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowVNetRDP'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '3389'
                    direction: 'Inbound'
                    priority: 550
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_LoadBalancer'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 1210
                    protocol: '*'
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_HealthProbes'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '65503-65534'
                    direction: 'Inbound'
                    priority: 1220
                    protocol: '*'
                    sourceAddressPrefix: 'Internet'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVNetInbound'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65000
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowAzureLoadBalancerInbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65001
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name:'DenyAllInbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVnetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65000
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowInternetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'Internet'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65001
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'DenyAllOutbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
        ]
    }
}

resource nsgCollection 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
    name: nsgCollectionName
    location: location
    properties: {
        securityRules: [
            {
                name: 'allowAppPortHttp'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTP'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '80'
                    direction: 'Inbound'
                    priority: 500
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'   
                }
            }
            {
                name: 'allowAppPortHttps'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTPS'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                    direction: 'Inbound'
                    priority: 510
                    protocol: '*'
                    sourceAddresssPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricCluster'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '1025-1027'
                    direction: 'Inbound'
                    priority: 520
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricEphemeral'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '49152-65534'
                    direction: 'Inbound'
                    priority: 530
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricSMB'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '445'
                    direction: 'Inbound'
                    priority: 540
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowVNetRDP'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '3389'
                    direction: 'Inbound'
                    priority: 550
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_LoadBalancer'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 1210
                    protocol: '*'
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_HealthProbes'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '65503-65534'
                    direction: 'Inbound'
                    priority: 1220
                    protocol: '*'
                    sourceAddressPrefix: 'Internet'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVNetInbound'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65000
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowAzureLoadBalancerInbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65001
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name:'DenyAllInbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVnetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65000
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowInternetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'Internet'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65001
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'DenyAllOutbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
        ]
    }
}

resource nsgManagement 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
    name: nsgManagementName
    location: location
    properties: {
        securityRules: [
            {
                name: 'allowAppPortHttp'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTP'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '80'
                    direction: 'Inbound'
                    priority: 500
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'   
                }
            }
            {
                name: 'allowAppPortHttps'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTPS'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                    direction: 'Inbound'
                    priority: 510
                    protocol: '*'
                    sourceAddresssPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricCluster'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '1025-1027'
                    direction: 'Inbound'
                    priority: 520
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricEphemeral'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '49152-65534'
                    direction: 'Inbound'
                    priority: 530
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricSMB'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '445'
                    direction: 'Inbound'
                    priority: 540
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowVNetRDP'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '3389'
                    direction: 'Inbound'
                    priority: 550
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_LoadBalancer'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 1210
                    protocol: '*'
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_HealthProbes'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '65503-65534'
                    direction: 'Inbound'
                    priority: 1220
                    protocol: '*'
                    sourceAddressPrefix: 'Internet'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'sfReverseProxy'
                properties: {
                    access: 'Allow'
                    description: 'Used by the reverse proxy across the cluster'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '19081'
                    direction: 'Inbound'
                    priority: 2050
                    protocol: '*'
                    sourceAddressPrefix: '173.219.157.16/32,52.177.130.253/32,71.221.192.187/32'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'ServiceFabric_ManagementEndpoint'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '19080'
                    direction: 'Inbound'
                    priority: 2060
                    protocol: 'Tcp'
                    sourceAddressPrefix: '173.219.157.16'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVNetInbound'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65000
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowAzureLoadBalancerInbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65001
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name:'DenyAllInbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVnetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65000
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowInternetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'Internet'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65001
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'DenyAllOutbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
        ]
    }
}

resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
    name: nsgWebName
    location: location
    properties: {
        securityRules: [
            {
                name: 'allowAppPortHttp'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTP'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '80'
                    direction: 'Inbound'
                    priority: 500
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'   
                }
            }
            {
                name: 'allowAppPortHttps'
                properties: {
                    access: 'Allow'
                    description: 'Allow application traffic via HTTPS'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                    direction: 'Inbound'
                    priority: 510
                    protocol: '*'
                    sourceAddresssPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricCluster'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '1025-1027'
                    direction: 'Inbound'
                    priority: 520
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricEphemeral'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '49152-65534'
                    direction: 'Inbound'
                    priority: 530
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowSvcFabricSMB'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '445'
                    direction: 'Inbound'
                    priority: 540
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'allowVNetRDP'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '3389'
                    direction: 'Inbound'
                    priority: 550
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_LoadBalancer'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 1210
                    protocol: '*'
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'applicationGateway_HealthProbes'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '65503-65534'
                    direction: 'Inbound'
                    priority: 1220
                    protocol: '*'
                    sourceAddressPrefix: 'Internet'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVNetInbound'
                properties: {
                    access: 'Allow'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65000
                    protocol: '*'
                    sourceAddressPrefix: 'VirtualNetwork'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowAzureLoadBalancerInbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65001
                    sourceAddressPrefix: 'AzureLoadBalancer'
                    sourcePortRange: '*'
                }
            }
            {
                name:'DenyAllInbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Inbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowVnetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65000
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'AllowInternetOutbound'
                properties: {
                    access: 'Allow'
                    protocol: '*'
                    destinationAddressPrefix: 'Internet'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65001
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
            {
                name: 'DenyAllOutbound'
                properties: {
                    access: 'Deny'
                    protocol: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                    direction: 'Outbound'
                    priority: 65500
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                }
            }
        ]
    }
}

//Service Fabric
param clusterCertificateUrl string {
    default: ''
    metadata: {
        description: 'Refers to the location URL in your key vault where the certificate was uploaded, it is should be in the format of https://<name of the vault>.vault.azure.net:443/secrets/<exact location>'
    }
}
param clusterCertificateIssuerThumbprint string = 'e6a3b45b062d509b3382282d196efe97d5956ccb'
//param clientCertificateUrl string = ''
param clusterProtectionLevel string = 'EncryptAndSign'
param certificateStore string = 'My'
param nodeTypeBackendName string = 'Backend'
param nodeTypeCollectionName string = 'Collection'
param nodeTypeManagementName string = 'Management'
param nodeTypeWebName string = 'Web'

resource sfCluster 'Microsoft.ServiceFabric/clusters@2018-02-01' = {
    name: application
    location: location
    dependsOn: [
        logStorage
        backendVmss
        collectionVmss
        managementVmss
        webVmss
    ]
    properties: {
        azureActiveDirectory: {
            clientApplication: '11d9f0a8-5da2-4002-9423-4d8afec53cd0'
            clusterApplication: '496693e1-eb0c-4d11-bf8c-9a586eeeb6b3'
            tenantId: '4129f61a-2f50-4f30-9676-043fa04064be'
        }
        addonFeatures: [
            'BackupRestoreService'
        ]
        certificateCommonNames: {
            commonNames: [
                {
                    certificateCommonName: certificateCommonName
                    certificateIssuerThumbprint: clusterCertificateIssuerThumbprint
                }
            ]
            x509StoreName: certificateStore
        }
        clientCertificateCommonNames: [
            /*{
                certificateCommonName: 'amber.innovian.dev'
                certificateIssuerThumbprint: clusterCertificateIssuerThumbprint
                isAdmin: true
            }*/
        ]
        clientCertificateThumbprint: []
        clusterState: 'Default'
        diagnosticsStorageAccountConfig: {
            tableEndpoint: '${logStorage.properties.primaryEndpoints.table}'
            blobEndpoint: '${logStorage.properties.primaryEndpoints.blob}'
            protectedAccountKeyName: 'StorageAccountKey1'
            queueEndpoint: '${logStorage.properties.primaryEndpoints.queue}'
            storageAccountName: '${logStorage.name}'
        }
        fabricSettings: [
            {
                name: 'BackupRestoreService'
                parameters: [
                    {
                        name: 'SecretEncryptionCertThumbprint'
                        value: 'da2ec555fff212b25ef44e284f72d6f5d1ff3673'
                    }
                    {
                        name: 'SecretEncryptionCertX509StoreName'
                        value: certificateStore
                    }
                ]
            }
            {
                name: 'Security'
                parameters: [
                    {
                        name: 'ClusterProtectionLevel'
                        value: clusterProtectionLevel
                    }
                ]
            }
            {
                name: 'ManagedIdentityTokenService'
                parameters: [
                    {
                        name: 'IsEnabled'
                        value: 'true'
                    }
                ]
            }
            {
                name: 'Management'
                parameters: [
                    {
                        name: 'CleanupApplicationPackageOnProvisionSuccess'
                        value: 'true'
                    }
                    {
                        name: 'CleanupUnusedApplicationTypes'
                        value: 'true'
                    }
                ]
            }
            {
                name: 'EventStoreService'
                parameters: [
                    {
                        name: 'TargetReplicaSetSize'
                        value: '3'
                    }
                    {
                        name: 'MinReplicaSetSize'
                        value: '1'
                    }
                ]
            }
        ]
        managementEndpoint: 'https://sapphire.innovian.dev:19080'
        nodeTypes: [
            {
                name: subnetBackendName
                applicationPorts: {
                    startPort: ntApplicationStartPort
                    endPort: ntApplicationEndPort
                }
                clientConnectionEndpointPort: ntFabricTcpGatewayPort
                durabilityLevel: 'Bronze'
                ephemeralPorts: {
                    startPort: ntEphemeralStartPort
                    endPort: ntEphemeralEndPort
                }
                httpGatewayEndpointPort: ntFabricHttpGatewayPort
                isPrimary: false
                vmInstanceCount: vmssBackendInstanceCount
            }
            {
                name: subnetWebName
                applicationPorts: {
                    startPort: ntApplicationStartPort
                    endPort: ntApplicationEndPort
                }
                clientConnectionEndpointPort: ntFabricTcpGatewayPort
                durabilityLevel: 'Bronze'
                ephemeralPorts: {
                    startPort: ntEphemeralStartPort
                    endPort: ntEphemeralEndPort
                }
                httpGatewayEndpointPort: ntFabricHttpGatewayPort
                isPrimary: false
                vmInstanceCount: vmssWebInstanceCount
            }
            {
                name: subnetCollectionName
                applicationPorts: {
                    startPort: ntApplicationStartPort
                    endPort: ntApplicationEndPort
                }
                clientConnectionEndpointPort: ntFabricTcpGatewayPort
                durabilityLevel: 'Bronze'
                ephemeralPorts: {
                    startPort: ntEphemeralStartPort
                    endPort: ntEphemeralEndPort
                }
                httpGatewayEndpointPort: ntFabricHttpGatewayPort
                isPrimary: false
                vmInstanceCount: vmssCollectionInstanceCount
            }
            {
                name: subnetManagementName
                applicationPorts: {
                    startPort: ntApplicationStartPort
                    endPort: ntApplicationEndPort
                }
                clientConnectionEndpointPort: ntFabricTcpGatewayPort
                durabilityLevel: 'Bronze'
                ephemeralPorts: {
                    startPort: ntEphemeralStartPort
                    endPort: ntEphemeralEndPort
                }
                httpGatewayEndpointPort: ntFabricHttpGatewayPort
                isPrimary: true
                vmInstanceCount: vmssManagementInstanceCount
            }
        ]
        provisioningState: 'Default'
        reliabilityLevel: 'Bronze'
        upgradeMode: 'Automatic'
        vmImage: vmssUseLinux ? 'Linux' : 'Windows'
    }
    tags: {
        environment: environment
    }
}


//VM Settings
param vmssUseLinux bool = true
param adminUsername string = 'innoviancore'
param adminPassword string {
    secure: true
}
//VM Skus
param vmImageOffer string = vmssUseLinux ? 'UbuntuServer' : 'WindowsServer'
param vmImagePublisher string = vmssUseLinux ? 'Canonical' : 'MicrosoftWindowsServer'
param vmImageSku string = vmssUseLinux ? '18.04-DAILY-LTS' : '2019-Datacenter-with-Containers'
param vmImageVersion string = vmssUseLinux ? '18.04.202010160' : 'latest'

param vmNodeTypeSize string = 'Standard_D2s_v3'
param vmssBackendInstanceCount int = 3
param vmssCollectionInstanceCount int = 3
param vmssManagementInstanceCount int = 3
param vmssWebInstanceCount int = 3
param certificateCommonName string = 'sapphire.innovian.dev'

resource backendVmss 'Microsoft.Compute/virtualMachineScaleSets@2020-06-01' = {
    name: nodeTypeBackendName
    location: location
    dependsOn: [
        vnet
        lbWeb
        diagStorage
        logStorage
    ]
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        overProvision: overProvision
        upgradePolicy: {
            mode: 'Automatic'
        }
        virtualMachineProfile: {
            extensionProfile: {
                extensions: [
                    {
                        name: 'customScript'
                        properties: {
                            publisher: 'Microsoft.Compute'
                            type: 'CustomScriptExtension'
                            typeHandlerVersion: '1.8'
                            autoUpgradeMinorVersion: true
                            settings: {
                                fileUris: [
                                    'https://invndevdeploymentscripts.blob.core.windows.net/deployment-scripts/diskfmt.ps1'
                                ]
                                commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File diskfmt.ps1'
                            }
                        }
                    }
                    {
                        name: '${nodeTypeWebName}_ServiceFabricNode'
                        properties: {
                            type: 'ServiceFabricNode'
                            autoUpgradeMinorVersion: true
                            protectedSettings: {
                                StorageAccountKey1: listKeys(diagStorage.id, diagStorage.apiVersion).key1 // listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key1]'
                                StorageAccountKey2: listKeys(diagStorage.id, diagStorage.apiVersion).key2
                            }
                            publisher: 'Microsoft.Azure.ServiceFabric'
                            settings: {
                                clusterEndpoint: ''
                                nodeTypeRef: nodeTypeWebName
                                dataPath: 'F:\\\\SvcFab'
                                durabilityLevel: 'Bronze'
                                enableParallelJobs: true
                                nicPrefixOverride: subnetWebPrefix
                                certificate: {
                                    commonNames: [
                                        certificateCommonName
                                    ]
                                    x509StorageName: certificateStore
                                }
                            }
                            typeHandlerVersion: '1.1'
                        }
                    }
                    //The following only makes sense given a Windows server VMSS, not Linux, but conditionals aren't yet covered
                    // {
                    //     name: 'VMDiagnosticsExt${nodeTypeWebName}'
                    //     properties: {
                    //         type: 'IaaSDiagnostics'
                    //         autoUpgradeMinorVersion: true
                    //         protectedSettings: {
                    //             storageAccountName: applicationDiagnosticsStorageAccountName
                    //             storageAccountKey: '[listKeys(resourceId("Microsoft.Storage/storageAccounts"), ${applicationDiagnosticsStorageAccountName}), "2015-05-01-preview").key1]'
                    //             storageAccountEndPoint: 'https://core.windows.net/'
                    //         }
                    //         publisher: 'Microsoft.Azure.Diagnostics'
                    //         settings: {
                    //             WadCfg: {
                    //                 DiagnosticsMonitorConfiguration: {
                    //                     overallQuotaInMB: 50000
                    //                     EtwProviders: {
                    //                         EtwEventSourceProviderConfiguration: [
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Actors'
                    //                                 scheduledTransferKeywordFilter: '1'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableActorEventTable'
                    //                                 }
                    //                             }
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Services'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableServiceEventTable'
                    //                                 }
                    //                             }
                    //                         ]
                    //                         EtwManifestProviderConfiguration: [
                    //                             {
                    //                                 provider: 'cbd93bc2-71e5-4566-b3a7-595d8eeca6e8'
                    //                                 scheduledTransferLogLevelFilter: 'Information'
                    //                                 scheduledTransferKeywordFilter: '4611686018427387904'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     'eventDestination': 'ServiceFabricSystemEventTable'
                    //                                 } 
                    //                             }
                    //                         ]
                    //                     }
                    //                 }
                    //             }
                    //             StorageAccount: applicationDiagnosticsStorageAccountName
                    //         }
                    //         typeHandlerVersion: '1.5'
                    //     }
                    // }
                ]
            }
        }
        networkProfile: {
            networkInterfaceConfigurations: [
                {
                    name: '${nicName}-web'
                    properties: {
                        ipConfigurations: [
                            {
                                name: '${nicName}-web'
                                properties: {
                                    loadBalancerBackendAddressPools: [
                                        {
                                            id: '${loadBalancerWebId}/backendAddressPools/${loadBalancerBackendAddressPoolName}'
                                        }
                                    ]
                                    loadBalancerInboundNatPools: [
                                        {
                                            id: '${loadBalancerWebId}/inboundNatPools/LoadBalancerBEAddressNATPool'
                                        }
                                    ]
                                    subnet: {
                                        id: '${vnet.id}/subnets/${subnetWebName}'
                                    }
                                }
                            }
                        ]
                        primary: true
                    }
                }
            ]
        }
        osProfile: {
            adminUsername: adminUsername
            adminPassword: adminPassword
            computernamePrefix: nodeTypeWebName
            secrets: [
                {
                    sourceVault: {
                        id: '/subscriptions/069d4115-2da2-4df9-a8ac-6409f17c9319/resourceGroups/Cluster/providers/Microsoft.KeyVault/vaults/InnoDevClusterKv'
                    }
                    vaultCertificates: [
                        //Cluster certificate
                        {
                            certificateStore: certificateStore
                            certificateUrl: clusterCertificateUrl
                        }
                        //Client certificate
                        /*{
                            certificateStorage: certificateStore
                            certificateUrl: clientCertificateUrl
                        }*/
                    ]
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: vmImagePublisher
                offer: vmImageOffer
                sku: vmImageSku
                version: vmImageVersion
            }
            osDisk: {
                caching: 'ReadOnly'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: storageSku
                }
            }
            dataDisks: [
                {
                    diskSizeGB: 128
                    lun: 0
                    createOption: 'Empty'
                }
            ]
        }
    }
    sku: {
        name: vmNodeTypeSize
        capacity: vmssWebInstanceCount
        tier: 'Standard'
    }
    tags: {
        'environment': environment
    }
}

resource collectionVmss 'Microsoft.Compute/virtualMachineScaleSets@2020-06-01' = {
    name: nodeTypeCollectionName
    location: location
    dependsOn: [
        vnet
        lbWeb
        diagStorage
        logStorage
    ]
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        overProvision: overProvision
        upgradePolicy: {
            mode: 'Automatic'
        }
        virtualMachineProfile: {
            extensionProfile: {
                extensions: [
                    {
                        name: 'customScript'
                        properties: {
                            publisher: 'Microsoft.Compute'
                            type: 'CustomScriptExtension'
                            typeHandlerVersion: '1.8'
                            autoUpgradeMinorVersion: true
                            settings: {
                                fileUris: [
                                    'https://invndevdeploymentscripts.blob.core.windows.net/deployment-scripts/diskfmt.ps1'
                                ]
                                commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File diskfmt.ps1'
                            }
                        }
                    }
                    {
                        name: '${nodeTypeWebName}_ServiceFabricNode'
                        properties: {
                            type: 'ServiceFabricNode'
                            autoUpgradeMinorVersion: true
                            protectedSettings: {
                                StorageAccountKey1: '[listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key1]'
                                StorageAccountKey2: '[listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key2]'
                            }
                            publisher: 'Microsoft.Azure.ServiceFabric'
                            settings: {
                                clusterEndpoint: ''
                                nodeTypeRef: nodeTypeWebName
                                dataPath: 'F:\\\\SvcFab'
                                durabilityLevel: 'Bronze'
                                enableParallelJobs: true
                                nicPrefixOverride: subnetWebPrefix
                                certificate: {
                                    commonNames: [
                                        certificateCommonName
                                    ]
                                    x509StorageName: certificateStore
                                }
                            }
                            typeHandlerVersion: '1.1'
                        }
                    }
                    //The following only makes sense given a Windows server VMSS, not Linux, but conditionals aren't yet covered
                    // {
                    //     name: 'VMDiagnosticsExt${nodeTypeWebName}'
                    //     properties: {
                    //         type: 'IaaSDiagnostics'
                    //         autoUpgradeMinorVersion: true
                    //         protectedSettings: {
                    //             storageAccountName: applicationDiagnosticsStorageAccountName
                    //             storageAccountKey: '[listKeys(resourceId("Microsoft.Storage/storageAccounts"), ${applicationDiagnosticsStorageAccountName}), "2015-05-01-preview").key1]'
                    //             storageAccountEndPoint: 'https://core.windows.net/'
                    //         }
                    //         publisher: 'Microsoft.Azure.Diagnostics'
                    //         settings: {
                    //             WadCfg: {
                    //                 DiagnosticsMonitorConfiguration: {
                    //                     overallQuotaInMB: 50000
                    //                     EtwProviders: {
                    //                         EtwEventSourceProviderConfiguration: [
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Actors'
                    //                                 scheduledTransferKeywordFilter: '1'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableActorEventTable'
                    //                                 }
                    //                             }
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Services'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableServiceEventTable'
                    //                                 }
                    //                             }
                    //                         ]
                    //                         EtwManifestProviderConfiguration: [
                    //                             {
                    //                                 provider: 'cbd93bc2-71e5-4566-b3a7-595d8eeca6e8'
                    //                                 scheduledTransferLogLevelFilter: 'Information'
                    //                                 scheduledTransferKeywordFilter: '4611686018427387904'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     'eventDestination': 'ServiceFabricSystemEventTable'
                    //                                 } 
                    //                             }
                    //                         ]
                    //                     }
                    //                 }
                    //             }
                    //             StorageAccount: applicationDiagnosticsStorageAccountName
                    //         }
                    //         typeHandlerVersion: '1.5'
                    //     }
                    // }
                ]
            }
        }
        networkProfile: {
            networkInterfaceConfigurations: [
                {
                    name: '${nicName}-web'
                    properties: {
                        ipConfigurations: [
                            {
                                name: '${nicName}-web'
                                properties: {
                                    loadBalancerBackendAddressPools: [
                                        {
                                            id: '${loadBalancerWebId}/backendAddressPools/${loadBalancerBackendAddressPoolName}'
                                        }
                                    ]
                                    loadBalancerInboundNatPools: [
                                        {
                                            id: '${loadBalancerWebId}/inboundNatPools/LoadBalancerBEAddressNATPool'
                                        }
                                    ]
                                    subnet: {
                                        id: '${vnet.id}/subnets/${subnetWebName}'
                                    }
                                }
                            }
                        ]
                        primary: true
                    }
                }
            ]
        }
        osProfile: {
            adminUsername: adminUsername
            adminPassword: adminPassword
            computernamePrefix: nodeTypeWebName
            secrets: [
                {
                    sourceVault: {
                        id: '/subscriptions/069d4115-2da2-4df9-a8ac-6409f17c9319/resourceGroups/Cluster/providers/Microsoft.KeyVault/vaults/InnoDevClusterKv'
                    }
                    vaultCertificates: [
                        //Cluster certificate
                        {
                            certificateStore: certificateStore
                            certificateUrl: clusterCertificateUrl
                        }
                        //Client certificate
                        /*{
                            certificateStorage: certificateStore
                            certificateUrl: clientCertificateUrl
                        }*/
                    ]
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: vmImagePublisher
                offer: vmImageOffer
                sku: vmImageSku
                version: vmImageVersion
            }
            osDisk: {
                caching: 'ReadOnly'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: storageSku
                }
            }
            dataDisks: [
                {
                    diskSizeGB: 128
                    lun: 0
                    createOption: 'Empty'
                }
            ]
        }
    }
    sku: {
        name: vmNodeTypeSize
        capacity: vmssWebInstanceCount
        tier: 'Standard'
    }
    tags: {
        'environment': environment
    }
}

resource managementVmss 'Microsoft.Compute/virtualMachineScaleSets@2020-06-01' = {
    name: nodeTypeManagementName
    location: location
    dependsOn: [
        vnet
        lbWeb
        diagStorage
        logStorage
    ]
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        overProvision: overProvision
        upgradePolicy: {
            mode: 'Automatic'
        }
        virtualMachineProfile: {
            extensionProfile: {
                extensions: [
                    {
                        name: 'customScript'
                        properties: {
                            publisher: 'Microsoft.Compute'
                            type: 'CustomScriptExtension'
                            typeHandlerVersion: '1.8'
                            autoUpgradeMinorVersion: true
                            settings: {
                                fileUris: [
                                    'https://invndevdeploymentscripts.blob.core.windows.net/deployment-scripts/diskfmt.ps1'
                                ]
                                commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File diskfmt.ps1'
                            }
                        }
                    }
                    {
                        name: '${nodeTypeWebName}_ServiceFabricNode'
                        properties: {
                            type: 'ServiceFabricNode'
                            autoUpgradeMinorVersion: true
                            protectedSettings: {
                                StorageAccountKey1: '[listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key1]'
                                StorageAccountKey2: '[listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key2]'
                            }
                            publisher: 'Microsoft.Azure.ServiceFabric'
                            settings: {
                                clusterEndpoint: ''
                                nodeTypeRef: nodeTypeWebName
                                dataPath: 'F:\\\\SvcFab'
                                durabilityLevel: 'Bronze'
                                enableParallelJobs: true
                                nicPrefixOverride: subnetWebPrefix
                                certificate: {
                                    commonNames: [
                                        certificateCommonName
                                    ]
                                    x509StorageName: certificateStore
                                }
                            }
                            typeHandlerVersion: '1.1'
                        }
                    }
                    //The following only makes sense given a Windows server VMSS, not Linux, but conditionals aren't yet covered
                    // {
                    //     name: 'VMDiagnosticsExt${nodeTypeWebName}'
                    //     properties: {
                    //         type: 'IaaSDiagnostics'
                    //         autoUpgradeMinorVersion: true
                    //         protectedSettings: {
                    //             storageAccountName: applicationDiagnosticsStorageAccountName
                    //             storageAccountKey: '[listKeys(resourceId("Microsoft.Storage/storageAccounts"), ${applicationDiagnosticsStorageAccountName}), "2015-05-01-preview").key1]'
                    //             storageAccountEndPoint: 'https://core.windows.net/'
                    //         }
                    //         publisher: 'Microsoft.Azure.Diagnostics'
                    //         settings: {
                    //             WadCfg: {
                    //                 DiagnosticsMonitorConfiguration: {
                    //                     overallQuotaInMB: 50000
                    //                     EtwProviders: {
                    //                         EtwEventSourceProviderConfiguration: [
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Actors'
                    //                                 scheduledTransferKeywordFilter: '1'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableActorEventTable'
                    //                                 }
                    //                             }
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Services'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableServiceEventTable'
                    //                                 }
                    //                             }
                    //                         ]
                    //                         EtwManifestProviderConfiguration: [
                    //                             {
                    //                                 provider: 'cbd93bc2-71e5-4566-b3a7-595d8eeca6e8'
                    //                                 scheduledTransferLogLevelFilter: 'Information'
                    //                                 scheduledTransferKeywordFilter: '4611686018427387904'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     'eventDestination': 'ServiceFabricSystemEventTable'
                    //                                 } 
                    //                             }
                    //                         ]
                    //                     }
                    //                 }
                    //             }
                    //             StorageAccount: applicationDiagnosticsStorageAccountName
                    //         }
                    //         typeHandlerVersion: '1.5'
                    //     }
                    // }
                ]
            }
        }
        networkProfile: {
            networkInterfaceConfigurations: [
                {
                    name: '${nicName}-web'
                    properties: {
                        ipConfigurations: [
                            {
                                name: '${nicName}-web'
                                properties: {
                                    loadBalancerBackendAddressPools: [
                                        {
                                            id: '${loadBalancerWebId}/backendAddressPools/${loadBalancerBackendAddressPoolName}'
                                        }
                                    ]
                                    loadBalancerInboundNatPools: [
                                        {
                                            id: '${loadBalancerWebId}/inboundNatPools/LoadBalancerBEAddressNATPool'
                                        }
                                    ]
                                    subnet: {
                                        id: '${vnet.id}/subnets/${subnetWebName}'
                                    }
                                }
                            }
                        ]
                        primary: true
                    }
                }
            ]
        }
        osProfile: {
            adminUsername: adminUsername
            adminPassword: adminPassword
            computernamePrefix: nodeTypeWebName
            secrets: [
                {
                    sourceVault: {
                        id: '/subscriptions/069d4115-2da2-4df9-a8ac-6409f17c9319/resourceGroups/Cluster/providers/Microsoft.KeyVault/vaults/InnoDevClusterKv'
                    }
                    vaultCertificates: [
                        //Cluster certificate
                        {
                            certificateStore: certificateStore
                            certificateUrl: clusterCertificateUrl
                        }
                        //Client certificate
                        /*{
                            certificateStorage: certificateStore
                            certificateUrl: clientCertificateUrl
                        }*/
                    ]
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: vmImagePublisher
                offer: vmImageOffer
                sku: vmImageSku
                version: vmImageVersion
            }
            osDisk: {
                caching: 'ReadOnly'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: storageSku
                }
            }
            dataDisks: [
                {
                    diskSizeGB: 128
                    lun: 0
                    createOption: 'Empty'
                }
            ]
        }
    }
    sku: {
        name: vmNodeTypeSize
        capacity: vmssWebInstanceCount
        tier: 'Standard'
    }
    tags: {
        'environment': environment
    }
}

resource webVmss 'Microsoft.Compute/virtualMachineScaleSets@2020-06-01' = {
    name: nodeTypeWebName
    location: location
    dependsOn: [
        vnet
        lbWeb
        diagStorage
        logStorage
    ]
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        overProvision: overProvision
        upgradePolicy: {
            mode: 'Automatic'
        }
        virtualMachineProfile: {
            extensionProfile: {
                extensions: [
                    {
                        name: 'customScript'
                        properties: {
                            publisher: 'Microsoft.Compute'
                            type: 'CustomScriptExtension'
                            typeHandlerVersion: '1.8'
                            autoUpgradeMinorVersion: true
                            settings: {
                                fileUris: [
                                    'https://invndevdeploymentscripts.blob.core.windows.net/deployment-scripts/diskfmt.ps1'
                                ]
                                commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File diskfmt.ps1'
                            }
                        }
                    }
                    {
                        name: '${nodeTypeWebName}_ServiceFabricNode'
                        properties: {
                            type: 'ServiceFabricNode'
                            autoUpgradeMinorVersion: true
                            protectedSettings: {
                                // af - todo - use native bicep code here
                                // this won't work with the latest release
                                StorageAccountKey1: '[listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key1]'
                                StorageAccountKey2: '[listKeys(resourceId("Microsoft.Storage/storageAccounts${supportLogAccountName}")).key2]'
                            }
                            publisher: 'Microsoft.Azure.ServiceFabric'
                            settings: {
                                clusterEndpoint: ''
                                nodeTypeRef: nodeTypeWebName
                                dataPath: 'F:\\\\SvcFab'
                                durabilityLevel: 'Bronze'
                                enableParallelJobs: true
                                nicPrefixOverride: subnetWebPrefix
                                certificate: {
                                    commonNames: [
                                        certificateCommonName
                                    ]
                                    x509StorageName: certificateStore
                                }
                            }
                            typeHandlerVersion: '1.1'
                        }
                    }
                    //The following only makes sense given a Windows server VMSS, not Linux, but conditionals aren't yet covered
                    // {
                    //     name: 'VMDiagnosticsExt${nodeTypeWebName}'
                    //     properties: {
                    //         type: 'IaaSDiagnostics'
                    //         autoUpgradeMinorVersion: true
                    //         protectedSettings: {
                    //             storageAccountName: applicationDiagnosticsStorageAccountName
                    //             storageAccountKey: '[listKeys(resourceId("Microsoft.Storage/storageAccounts"), ${applicationDiagnosticsStorageAccountName}), "2015-05-01-preview").key1]'
                    //             storageAccountEndPoint: 'https://core.windows.net/'
                    //         }
                    //         publisher: 'Microsoft.Azure.Diagnostics'
                    //         settings: {
                    //             WadCfg: {
                    //                 DiagnosticsMonitorConfiguration: {
                    //                     overallQuotaInMB: 50000
                    //                     EtwProviders: {
                    //                         EtwEventSourceProviderConfiguration: [
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Actors'
                    //                                 scheduledTransferKeywordFilter: '1'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableActorEventTable'
                    //                                 }
                    //                             }
                    //                             {
                    //                                 provider: 'Microsoft-ServiceFabric-Services'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     eventDestination: 'ServiceFabricReliableServiceEventTable'
                    //                                 }
                    //                             }
                    //                         ]
                    //                         EtwManifestProviderConfiguration: [
                    //                             {
                    //                                 provider: 'cbd93bc2-71e5-4566-b3a7-595d8eeca6e8'
                    //                                 scheduledTransferLogLevelFilter: 'Information'
                    //                                 scheduledTransferKeywordFilter: '4611686018427387904'
                    //                                 scheduledTransferPeriod: 'PT5M'
                    //                                 DefaultEvents: {
                    //                                     'eventDestination': 'ServiceFabricSystemEventTable'
                    //                                 } 
                    //                             }
                    //                         ]
                    //                     }
                    //                 }
                    //             }
                    //             StorageAccount: applicationDiagnosticsStorageAccountName
                    //         }
                    //         typeHandlerVersion: '1.5'
                    //     }
                    // }
                ]
            }
        }
        networkProfile: {
            networkInterfaceConfigurations: [
                {
                    name: '${nicName}-web'
                    properties: {
                        ipConfigurations: [
                            {
                                name: '${nicName}-web'
                                properties: {
                                    loadBalancerBackendAddressPools: [
                                        {
                                            id: '${loadBalancerWebId}/backendAddressPools/${loadBalancerBackendAddressPoolName}'
                                        }
                                    ]
                                    loadBalancerInboundNatPools: [
                                        {
                                            id: '${loadBalancerWebId}/inboundNatPools/LoadBalancerBEAddressNATPool'
                                        }
                                    ]
                                    subnet: {
                                        id: '${vnet.id}/subnets/${subnetWebName}'
                                    }
                                }
                            }
                        ]
                        primary: true
                    }
                }
            ]
        }
        osProfile: {
            adminUsername: adminUsername
            adminPassword: adminPassword
            computernamePrefix: nodeTypeWebName
            secrets: [
                {
                    sourceVault: {
                        id: '/subscriptions/069d4115-2da2-4df9-a8ac-6409f17c9319/resourceGroups/Cluster/providers/Microsoft.KeyVault/vaults/InnoDevClusterKv'
                    }
                    vaultCertificates: [
                        //Cluster certificate
                        {
                            certificateStore: certificateStore
                            certificateUrl: clusterCertificateUrl
                        }
                        //Client certificate
                        /*{
                            certificateStorage: certificateStore
                            certificateUrl: clientCertificateUrl
                        }*/
                    ]
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: vmImagePublisher
                offer: vmImageOffer
                sku: vmImageSku
                version: vmImageVersion
            }
            osDisk: {
                caching: 'ReadOnly'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: storageSku
                }
            }
            dataDisks: [
                {
                    diskSizeGB: 128
                    lun: 0
                    createOption: 'Empty'
                }
            ]
        }
    }
    sku: {
        name: vmNodeTypeSize
        capacity: vmssWebInstanceCount
        tier: 'Standard'
    }
    tags: {
        'environment': environment
    }
}

//Storage account
param storageSku string = 'Standard_LRS'
param supportLogAccountType string = storageSku
param supportLogAccountName string = 'invnsflogs'
param applicationDiagnosticsStorageAccountType string = storageSku
param applicationDiagnosticsStorageAccountName string = 'invnwad'

resource diagStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: supportLogAccountName
    location: location
    tags: {
        'environment': environment
    }
    kind: 'Storage'
    sku: {
        name: supportLogAccountType
    }
    properties: {}
}

resource logStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: applicationDiagnosticsStorageAccountName
    location: location
    tags: {
        'environment': environment
    }
    kind: 'Storage'
    sku: {
        name: applicationDiagnosticsStorageAccountType
    }
    properties: {
        
    }
}


//Application gateway
/*
resource applicationGateway 'Microsoft.Network/applicationGateways@2020-05-01' = {
    name: 'InvnAppGateway001'
    location: location
    tags: {
        environment: environment
    }
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        autoScleConfiguration: {
            maxCapacity: 1
            minCapacity: 1
        }
        backendAddressPools: [

        ]   
        backendHttpSettingsCollection: [

        ]


    }
}
*/