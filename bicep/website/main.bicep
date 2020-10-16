param location string = resourceGroup().location
param acrPassword string {
  secure: true
}
param sqlServerPassword string {
  secure: true
}

module appService './appServiceContainer.bicep' = {
  name: 'webdeploy' // name of the nested deployment
  params: {
    name: 'lfa2'
    location: location
    acrName: 'lawrencefarmsantiques'
    dockerUsername: 'lfaAdmin'
    dockerPassword: acrPassword
    dockerImageAndTag: 'lfa/frontend:latest'
  }
}

module sqlServerAndDb './sqlServerAndDb.bicep' = {
  name: 'sqldeploy'
  params: {
    serverName: 'lfa2'
    dbName: 'db'
    location: location
    username: 'adminUser'
    password: sqlServerPassword
  }
}

output myOutput string = appService.outputs.websiteId