param acrPassword string
param sqlServerPassword string
param location string = resourceGroup().location

module appService './webapp.bicep' = {
  name: 'lfadeploy'
  params: {
    name: 'lfa2'
    location: location
    acrName: 'lawrencefarmsantiques'
    dockerUsername: 'lfaAdmin'
    dockerPassword: acrPassword
    dockerImageAndTag: 'lfa/frontend:latest'
  }
}

module sqlServerAndDb './datatier.bicep' = {
  name: 'datadeploy'
  params: {
    serverName: 'lfa2'
    dbName: 'db'
    location: location
    username: 'adminUser'
    password: sqlServerPassword
  }
}

output myOutput string = appService.outputs.websiteId