# Blueprints 2.0 schema

## Why does the schema need to be updated?
There are two main reasons:
1. The main blueprint.json file is hard to scan. In order to get even a decent picture of what a blueprint does, I need to look at every blueprint file to know which scope the resource will be deployed to and to see any dependencies that exist and therefore the deployment sequence.
    * Today, an artifact couples two concerns (the “what” of the artifact and the “where/in what order” of the artifact. De-coupling these should make development easier and improve re-usability/portability of artifacts.
2. Parameters are a significant challenge to managing blueprints-as-code (especially from the scratch)
    * The UI does a good job hiding this complexity, but you are forced to understand every detail when you switch to code
    * All artifact parameters must have a corresponding blueprint parameters. This feels like a tax as parameters need to be declared multiple times which seems redundant. This makes bugs and reference errors more common than they need to be.

### Blueprint.json
The main change here is bringing the list of artifacts **into** the blueprint json. The actual details of what is in the artifact remain in the artifact.json. The names in the blueprint.json artifact array have to match the corresponding name property of the artifact object (or filename of artifact if that property is not explicitly declared).

```json
{
    "properties": {
        "description": "My Blueprint As Code",
        "targetScope": "subscription",
        "parameters": { 
           "blueprintLocation": {
               "type": "string",
               "defaultValue": "westus"
           } 
        },
        "resourceGroups": {
            "RG1": {
                "location": "westus"
            }
        },
        "artifacts": [
            {
                "name": "artifact1",
                "resourceGroup": "RG1",
                "parameters": {
                    "artifactParam1": {
                        "value": "paramValue" // hardcoded parameter value, easy to see from main bp file
                    },
                    "location": {
                        "value": "[parameters('blueprintLocation')]"
                    }
                }
            },
            {
                "name": "artifact2",
                "dependsOn": ["artifact1"]
            }
        ]
    },
    "type": "Microsoft.Blueprint/blueprints" 
}
```

### Artifact1.json
The change is to support “artifactParameters” separate from “blueprintParameters”. Ideally, artifactParameters can be implicitly defined. If a blueprint parameter doesn’t exist, it should be filled out only at assignment time.

We also decoupling info from the artifact.json and moving it into the artifacts list in blueprint.json. This should make the artifacts more re-usable, more "drag & drop".

```json
{
    "kind": "template",
    "properties": {
        "template": {
            "parameters": {},
            "resources": [
                // need to reference a bp parameter directly here
                {
                    "name": "myStorageAccount",
                    "type": "Microsoft.Storage/storageAccounts",
                    "apiVersion": "2016-01-01",
                    "sku": {
                        "name": "Standard_LRS"
                    },
                    "kind": "Storage",
                    "location": "[parameters('blueprintLocation')]", // direct reference of a bp parameter
                    "tags": {},
                    "properties": {}
                }
            ]
        }
    }
}
```

### Assignment.json
The assignment json needs to be updated to support artifactParameters. blueprintParameters and artifactParameters are now called out separately. The user (or UI/powershell) is responsible for understanding which is which.

```json
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
      "artifactParameters": // this is the part I am most unsure about, seems too verbose..
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
