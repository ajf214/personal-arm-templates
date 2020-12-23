param location string = 'westus'
param timestamp string = utcNow()
param dsName string = 'ds${uniqueString(resourceGroup().name)}'

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzureCLI'
  name: dsName
  location: location
  // identity property no longer required
  properties: {
    azCliVersion: '2.15.1'
    arguments: 'one two three'
    scriptContent: 'echo $3'
    forceUpdateTag: timestamp // script will run every time
    retentionInterval: 'PT4H' // deploymentScript resource will delete itself in 4 hours
  }
}

// output scriptOutput string = script.properties.outputs.test
output dsNameOut string = script.name