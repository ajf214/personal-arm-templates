param postgresSqlServer object = {
  name: 'alfrandb'
}

resource postgres 'microsoft.dbforpostgreSql/servers@2017-12-01' = {
  name: '${postgresSqlServer.name}${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'GP_Gen5_2'
    capacity: 2
    family: 'Gen5'
    size: '5120' // does this need to be a string?
  }
  properties: {
    // version: 11
    administratorLogin: 'alex'
    administratorLoginPassword: 'P@ssw0rd1234'
    // storageProfile: {
    //   storageMB: 5*1024
    //   backupRetentionDays: postgresSqlServer.backupRetentionDays
    //   geoRedundantBackup: postgresSqlServer.geoRedundantBackup
    //   storageAutoGrow: postgresSqlServer.storageAutogrow
    // }
    // sslEnforcement: 'Enabled'
    createMode: 'Default'
    // minimalTlsVersion: 'TLS1_0'
    // publicNetworkAccess: 'Enabled'
    // infrastructureEncryption: postgresSqlServer.infrastructureEncryption
  }
}