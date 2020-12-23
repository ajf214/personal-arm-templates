targetScope = 'subscription'

module mod './module.bicep' = {
  scope: resourceGroup('test')
  name: 'test'
}