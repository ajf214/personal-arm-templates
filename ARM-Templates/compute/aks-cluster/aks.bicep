param clusterName string {
  metadata: {
    description: 'The name of the Managed Cluster resource.'
  }
  default: 'aks101cluster'
}
param location string {
  metadata: {
    description: 'The location of the Managed Cluster resource.'
  }
  default: resourceGroup().location
}
param dnsPrefix string {
  metadata: {
    description: 'Optional DNS prefix to use with hosted Kubernetes API server FQDN.'
  }
}
param osDiskSizeGB int {
  minValue: 0
  maxValue: 1023
  metadata: {
    description: 'Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.'
  }
  default: 0
}
param agentCount int {
  minValue: 1
  maxValue: 50
  metadata: {
    description: 'The number of nodes for the cluster.'
  }
  default: 3
}
param agentVMSize string {
  metadata: {
    description: 'The size of the Virtual Machine.'
  }
  default: 'Standard_DS2_v2'
}
param linuxAdminUsername string {
  metadata: {
    description: 'User name for the Linux Virtual Machines.'
  }
}
param sshRSAPublicKey string {
  metadata: {
    description: 'Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\''
  }
}
param servicePrincipalClientId string {
  metadata: {
    description: 'Client ID (used by cloudprovider)'
  }
  secure: true
}
param servicePrincipalClientSecret string {
  metadata: {
    description: 'The Service Principal Client Secret.'
  }
  secure: true
}
param osType string {
  allowed: [
    'Linux'
  ]
  metadata: {
    description: 'The type of operating system.'
  }
  default: 'Linux'
}
param kubernetesVersion string {
  metadata: {
    description: 'The version of Kubernetes.'
  }
  default: '1.14.8'
}
resource aks 'Microsoft.ContainerService/managedClusters@2018-03-31' = {
  location: location
  name: clusterName
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: osType
        storageProfile: 'ManagedDisks'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    servicePrincipalProfile: {
      clientId: servicePrincipalClientId
      Secret: servicePrincipalClientSecret
    }
  }
}

output controlPlaneFQDN string = reference(clusterName).fqdn
