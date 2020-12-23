
param serverName string 
param dbName string
param location string
param username string = 'admin'
param password string

resource sqlServer 'microsoft.sql/servers@2019-06-01-preview' = {
  name: serverName
  location: location
  kind: 'v12.0'
  properties: {
    administratorLogin: username
    administratorLoginPassword: password
    version: '12.0'
  }
}

resource sqlDb 'microsoft.sql/servers/databases@2019-06-01-preview' = {
  name: '${sqlServer.name}/${dbName}' // child resources must have parent as first segment
  location: location
  sku: {
    name: 'Basic'
    capacity: 5
  }
  kind: 'v12.0,user'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: '2147483648' // todo - switch back to int/number once issue #486 is resolved
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    readReplicaCount: 0
    storageAccountType: 'GRS'
  }
} 