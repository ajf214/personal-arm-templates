var policyName = 'restrict-allowed-locations'

resource policy 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    metadata: {
      category: 'General'
    }
    mode: 'All'
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          strongType: 'location'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: '[parameters(\'allowedLocations\')]'
          }
          {
            field: 'location'
            notEquals: 'global'
          }
          {
            field: 'type'
            notEquals: 'Microsoft.AzureActiveDirectory/b2cDirectories'
          }
        ]
      }
      then: {
        effect: 'Deny'
      }
    }
  }
}