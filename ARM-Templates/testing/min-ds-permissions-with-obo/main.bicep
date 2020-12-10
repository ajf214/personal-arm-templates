param location string = 'westus'
param timestamp string = utcNow()
param dsName string = 'ds${uniqueString(resourceGroup().name)}'

var uamiId = '/subscriptions/e93d3ee6-fac1-412f-92d6-bfb379e81af2/resourceGroups/alex-test-feb/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alfran-test-ds-min-permissions'

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  name: dsName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  // identity property no longer required
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: '$DeploymentScriptOutputs["test"] = Get-AzContext'
    forceUpdateTag: timestamp // script will run every time
    retentionInterval: 'PT4H' // deploymentScript resource will delete itself in 4 hours
  }
}

output scriptOutput object = script.properties.outputs.test