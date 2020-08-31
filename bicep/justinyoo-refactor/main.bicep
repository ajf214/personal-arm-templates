param name string
param suffix string
param location string {
  allowed: [
    'australiaeast'
    'koreacentral'
    'westus2'
  ]
  default: resourceGroup().location
}

// what does the location code do?
param locationCode string {
  allowed: [
    'aue'
    'krc'
    'wus2'
  ]
  default: 'krc'
}
  
// Unique DNS Name for the Public IP used to access the Virtual Machine.
param publicIpDnsLabel string

// CIDR notation of the Virtual Networks.
param virtualNetworkAddressPrefix string = '10.0.0.0/16'

// CIDR notation of the Virtual Network Subnets.
param virtualNetworkSubnetPrefix string = '10.0.0.0/24'
  
param virtualMachineAdminUsername string
param virtualMachineAdminPassword string {
  secure: true
}

param virtualMachineSize string {
  allowed: [
    'Standard_D2s_v3'
    'Standard_D4s_v3'
    'Standard_D8s_v3'
  ]
  default: 'Standard_D8s_v3'
}

param virtualMachinePublisher string {
  allowed: [
    'MicrosoftVisualStudio'
    'MicrosoftWindowsDesktop'
  ]
  default: 'MicrosoftWindowsDesktop'
}

param virtualMachineOffer string {
  allowed: [
    'visualstudio2019latest'
    'Windows-10'
  ]
  default: 'Windows-10'
}

// The Windows version for the VM. This will pick a fully patched image of this given Windows version.
param virtualMachineSku string {
  allowed: [
    'vs-2019-comm-latest-ws2019'
    'vs-2019-ent-latest-ws2019'
    '20h1-pro-g2'
    '20h1-ent-g2'
  ]
  default: '20h1-pro-g2'
}

param virtualMachineExtensionCustomScriptUri string = 'https://raw.githubusercontent.com/devkimchi/LiveStream-VM-Setup-Sample/main/install.ps1'

var metadata = {
  longName: '{0}-${name}-${locationCode}${coalesce(suffix, '') == '' ? '' : ''}'
  shortName: '{0}${replace(name, '-', '')}${locationCode}${coalesce(suffix, '') == '' ? '' : ''}'
}
  
resource st 'Microsoft.Storage/storageAccounts@2017-10-01' = {
  name: replace(metadata.shortName, '{0}', 'st')
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2018-07-01' = {
  name: replace(metadata.longName, '{0}', 'pip')
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${coalesce(publicIpDnsLabel, '') == '' ? replace(metadata.shortName, '{0}', 'vm') : publicIpDnsLabel}'
    }
  }
}
  
var securityRules = [
  {
    name: 'default-allow-3389'
    properties: {
      priority: 1000
      access: 'Allow'
      direction: 'Inbound'
      protocol: 'TCP'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: 3389
    }
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2018-07-01' = {
  name: replace(metadata.longName, '{0}', 'nsg')
  location: location
  properties: {
    securityRules: securityRules
  }
}

var subnetName = 'default'
var subnets = [
  {
    name: subnetName
    properties: {
      addressPrefix: virtualNetworkSubnetPrefix
      networkSecurityGroup: {
        id: nsg.id
      }
    }
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2018-07-01' = {
  name: replace(metadata.longName, '{0}', 'vnet')
  location: location
  dependsOn: [
    nsg
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [ 
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnets
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2018-07-01' = {
  name: replace(metadata.longName, '{0}', 'nic')
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetName)
          }
        }
      }
    ]
  }
} 
  
resource vm 'Microsoft.Compute/virtualMachines@2018-10-01' = {
  name: replace(metadata.shortName, '{0}', 'vm')
  location: location
  dependsOn: [
    nic
  ]
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    osProfile: {
      computerName: replace(metadata.shortName, '{0}', 'vm')
      adminUsername: virtualMachineAdminUsername
      adminPassword: virtualMachineAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: virtualMachinePublisher
        offer: virtualMachineOffer
        sku: virtualMachineSku
        version: 'latest'
      }
      osDisk: {
        name: replace(metadata.longName, '{0}', 'osdisk')
        createOption: 'FromImage'
        // osDisk.caching is in var but not included here...
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: nic.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: st.properties.primaryEndpoints.blob
      }
    }
  }
}
  
resource vmext 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  name: '${vm.name}/config-app'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        virtualMachineExtensionCustomScriptUri
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ./${last(split(virtualMachineExtensionCustomScriptUri, '/'))}'
    }
  }
}