# Blueprints 2.0 schema

## Why does the schema need to be updated?
There are two main reasons:
1. The main blueprint.json file is hard to scan. In order to get even a decent picture of what a blueprint does, I need to look at every blueprint file to know which scope the resource will be deployed to and to see any dependencies that exist and therefore the deployment sequence.
    * An artifact couples two concerns (the “what” of the artifact and the “where/in what order” of the blueprint. De-coupling these should make development easier.
1. Parameters are a significant challenge to starting with blueprints-as-code from the start
    * The UI does a good job hiding this complexity, but you are forced to understand every detail when you switch to code
    * All artifact parameters must have a corresponding blueprint parameters. This feels like a tax as parameters need to be declared twice. This makes bugs and reference errors more common than they need to be

### Blueprint.json
The main change here is bringing the list of artifacts into the blueprint json. The actual details of what is in the artifact are in the artifact.json. The names in the blueprint.json have to match the corresponding name which is a property of the artifact object.

```
{
    "properties": {
        "description": "MyER Blueprint",
        "targetScope": "subscription",
        "parameters": { 
           
        },
        "resourceGroups": {
            "MyER": {
                "location": "westus"
            }
        },
        "artifacts": [
            {
                "name": "artifact-name",
                "resourceGroup": "MyER",
                "dependsOn": ["other-artifact-or-resource-group"],
                "parameters": {
                    "param1": {
                        "value": "paramValue"
                    }
                }
            },
            {
                "name": "second-artifact",
                "dependsOn": ["artifact-name"]
            }
        ]
    },
    "type": "Microsoft.Blueprint/blueprints" 
}
```

### Artifact.json
The change is to support “artifactParameters” separate from “blueprintParameters”. Ideally, artifactParameters can be implicitly defined. If a blueprint parameter doesn’t exist, it should be filled out only at assignment time.

We also decoupling info from the artifact.json and moving it into the artifacts list in blueprint.json. This should make the artifacts more re-usable, more "drag & drop".

```
{
    "kind": "template",
    "properties": {
        "template": {
            "parameters": {},
            "resources": []
        }
    }
}
```

### Assignment.json
The assignment json needs to be updated to support artifactParameters. blueprintParameters and artifactParameters are now called out separately. The user (or UI/powershell) is responsible for understanding which is which.

```
{
    "identity": {
      "type": "SystemAssigned"
    },
    "location": "eastus",
    "properties": {
      "description": "enforce pre-defined simpleBlueprint to this XXXXXXXX subscription.",
      "blueprintId": "/providers/Microsoft.Management/managementGroups/ContosoOnlineGroup/providers/Microsoft.Blueprint/blueprints/simpleBlueprint",
      "bluprintParameters": {
        "storageAccountType": {
          "value": "Standard_LRS"
        },
        "costCenter": {
          "value": "Contoso/Online/Shopping/Production"
        },
        "owners": {
          "value": [
            "johnDoe@contoso.com",
            "johnsteam@contoso.com"
          ]
        }
      },
      "artifactParameters":
      [
          {
              "artifactName": "artifact", // I don't love that I need to explicitly declare the artifact i'm passing a param for
              "parameters": {
                  "paramName": {
                      "value": "myParameterValue"
                  },
                  "secondParam": {
                      "value": "anotherParamValue"
                  }
              }
          }
      ],
      "resourceGroups": {
        "storageRG": {
          "name": "defaultRG",
          "location": "eastus"
        }
      }
    }
  }
```
