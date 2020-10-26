module stgMod './storage.bicep' = {
  name: 'storageDeploy'
  params: {
    location: 'westus'
    namePrefix: 'john'
  }
}

output id string = stgMod.outputs.stgId