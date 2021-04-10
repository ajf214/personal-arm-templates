resource foo 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: 'foo'
  location: 'eastus'
  kind: 'linux' // need help here
  properties: {
    reserved: true // this has to be true to get a linux instance - why is that?
  }
}

resource bar 'Microsoft.Web/sites@2020-10-01' = {
  name: 'foo'
  location: 'eastus'
  kind: 'function' // no help here, is the default a web app?
  // ASK: add enums and treat this property as a discriminator
  // * what are the most common?
  properties: {
    siteConfig: {
      appSettings: [ /* no help */ ]
      linuxFxVersion: 'DOCKER|repo/name:tag' // swagger supports open-ended enums, bicep doesn't support it yet
      // ASK: add result of "az webapp list-runtimes" that is discriminated based on kind
      // ASK: add "DOCKER|repo/name:tag" enum
    }
  }
}

/*
api bad behaviors
 - returning a bunch of properties as null (because some are secret)
  * they should still mark it as secret if that's how they are handling it?
   - grab the what-if error
   - they seem to have the logic when doing a GET on sites/config, but not sites.properties.siteConfig
  * if I can GET appSettings I already have a lot of permissions?
*/
