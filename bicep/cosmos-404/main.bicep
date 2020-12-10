var basename = 'alfran'
var location = resourceGroup().location
var failover_location = 'westus'

resource cosmos_account 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: '${basename}cosmosaccount'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        failoverPriority: 1
        locationName: failover_location
      }
      {
        failoverPriority: 0
        locationName: location
      }
    ]
  }
}

resource cosmos_sqldb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
  name: '${cosmos_account.name}/memealyzer'
  properties: {
    options: {
      throughput: 400
    }
    resource: {
      id: 'memealyzer'
    }
  }
}

resource cosmos_sqldb_container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2020-04-01' = {
  name: '${cosmos_sqldb.name}/images'
  properties: {
    options: {
      throughput: 400
    }
    resource: {
      partitionKey: {
        paths: [
          '/uid'
        ]
      }
      id: 'images'
      uniqueKeyPolicy: {
        uniqueKeys: [
          {
            paths: [
              '/uid'
            ]
          }
        ]
      }
    }
  }
}