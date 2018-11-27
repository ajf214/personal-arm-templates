<!-- 
Version 0.1 
Last edited: 11-26-18
-->
# Managing Blueprints as Code

#### !! Disclaimer !!
This doc is based on a powershell script that is managed by the community and is not officially supported by Microsoft. The Blueprints team is fast at work finishing official powershell cmdlets and azure cli commands.

## Prerequisites

This doc assumes you have a basic understanding of how blueprints work. If you've never used Blueprints before, this will be a little overwhelming. We recommend you build your first blueprint with the UI to understand how everything works. You can try it at [aka.ms/getblueprints](https://aka.ms/getblueprints) and learn more about it in the [docs](link-to-docs) or watch this [10 minute overview]().

Download the [Manage-AzureRMBlueprint script](https://powershellgallery.com/packages/Manage-AzureRMBlueprint) from the powershell gallery. At the time of this writing the latest is version 2.0. In addition to helping you manage your Blueprints as Code, this script is also helpful for moving a Blueprint between Management Groups or between Azure Tenants.
Using the Blueprints in the Azure Portal is a great way to get started with Blueprints or to use Blueprints on a small-ish scale, but often you’ll want to manage your Blueprints as code for a variety of reasons, such as:
* Sharing blueprints
* Keeping blueprints in source control
* Putting blueprints in a CI/CD or release pipeline

## Structure of blueprint artifacts
A blueprint consists of the main blueprint json file and a series of artifact json files. Simple 😊
<img src="image of blueprint directory" />

### Blueprint folder
Create a folder or directory on your computer to store all of your blueprint files. **The name of this folder will be the default name of the blueprint** unless you specify a new name in the blueprint json file.

### Functions
At the time we support the following functions. They work [exactly like they do](some-helpful-link) in a regular ARM template.
* parameters()
* concat()

### Blueprint
This is your main Blueprint file. In order to be processed successfully, the blueprint must be created in Azure before any artifacts (policy, role, template) otherwise the calls to publish those artifacts will fail. That's because the **artifacts are child resources of a blueprint**. The Manage-AzureRmBlueprint script takes care of this for you automatically. Typically, you will name this 01-blueprint.json so that it is sorted alphabetically first, but this name is up to you and doesn't affect anything.


Here’s a simple sample blueprint.json file:
```
{
    "properties": {
        "description": "This will be displayed in the essentials, so make it good",
        "targetScope": "subscription",
        "parameters": { 
            "principalIds": {
                "type": "string",
                "metadata": {
                    "displayName": "Display Name for Blueprint parameter",
                    "descripiton": "This is a blueprint parameter that any artifact can reference. We'll display these descriptions for you in the info bubble",
                    "strongType": "PrincipalId"
                }
            },
            "genericBlueprintParameter": {
                "type": "string"
            }
        },
        "resourceGroups": {
            "SingleRG": {
                "description": "An optional description for your RG artifact. FYI location and name properties can be left out and we will assume they are assignment-time parameters",
                "location": "eastus"
            }
        }
    },
    "type": "Microsoft.Blueprint/blueprints" 
}
```
Some key takeaways to note from this example:
* There are two optional blueprint parameters: ```principalIds``` and ```genericBlueprintParameter```. These parameters can be referenced in any artifact.
* The ```resourceGroups``` artifacts are declared here, not in their own files.


### Resource Group properties
You'll notice the **resource group artifacts are defined within the main blueprint json file**. This is confusing kind of, but it is what it is. Here we have a resource group that does the following: 
 * Hardcodes a location of ```eastus```
 * Sets a placeholder name ```SingleRG``` for the resource group. This means the resource group name will be determined at assignment time
     - optionally you could hardcode the resource group name by adding ```"name": "myRgName"``` 

[Full spec of a blueprint](https://docs.microsoft.com/en-us/rest/api/blueprints/blueprints/createorupdate#blueprint)

### Artifacts

Let’s look at a simple policy artifact here:
```
{
    "properties": {
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/a451c1ef-c6ca-483d-87ed-f49761e3ffb5",
        "parameters": {},
        "dependsOn": [],
        "displayName": "My Policy Definition that will be assigned (Currently auditing usage of custome roles)"
    },
    "kind": "policyAssignment",
    "type": "Microsoft.Blueprint/blueprints/artifacts"
}
```

All artifacts share common properties:
* ```Kind``` – the artifact type. Can be:
    - ```template```
    - ```roleAssignment```
    - ```policyAssignment```
* ```Type``` – this will always be: ```Microsoft.Bluprint/blueprints/artifacts```
* ```properties``` – this is what defines the artifact itself. Some properties of ```properties``` are common while others are specific to each type.
    - Common properties
        - ```dependsOn```
        - ```resourceGroup``` – optional. Use the resource group placeholder name to target this artifact to that resource group. If this property isn't specified it will target the subscription.

Full spec for each artifact type:

* [Policy Assignment](https://docs.microsoft.com/en-us/rest/api/blueprints/artifacts/createorupdate#policyassignmentartifact)
* [Role Assignment](https://docs.microsoft.com/en-us/rest/api/blueprints/artifacts/createorupdate#roleassignmentartifact)
* [Template](https://docs.microsoft.com/en-us/rest/api/blueprints/artifacts/createorupdate#templateartifact)

### How Parameters work
Nearly everything can be parameterized. The only things that can't be parameterized are the ```roleDefinitionId``` and ```policyDefinitionId``` in the ```rbacAssignment``` and ```policyAssignment``` artifacts respectively. Some explanation for why this is, something about linked access checks.
Parameters are set on the main blueprint file and can be referenced in any artifact. 

You create a parameter like this in ```blueprint.json```
```
{example}
```

And you reference a parameter like this in any artifact:
```
{example}
```

This gets a little complicated when you want to pass those variables to an artifact that, itself, can also have parameters. You first need to map the blueprint parameter to the artifact parameter like this:
```
{example}
```

And then you can reference that parameter in the artifact like this:
```
{example}
```

The [AxAzureBlueprint](https://www.powershellgallery.com/packages/AxAzureBlueprint/1.0.0) script has a cmdlet called ```Import-AzureBlueprintArtifact``` that can automatically convert an ARM template into a blueprint template artifact and map all the parameter references for you. It's a good way to understand how everything works.

### Push the Blueprint definition to Azure
Now we’ll take advantage of the [Manage-AzureRMBlueprint]() script and push it to Azure. We can do so by running the following command. You should be in the directory of where your blueprint artifacts are saved.
```
Manage-AzureRMBlueprint -mode Import -ImportDir “.” -ManagementGroupID “ManagementGroupId”
```

You will be asked to choose a subscription that is in the tenant where you want to save the blueprint definition, then confirm that it is ok to save something in your Azure subscription. Or you can use ```-Force``` to skip the confirmation. 

Now you should see a new blueprint definition in Azure. You can update the blueprint by simply re-running the above command.

That’s it!

You might run into some issues. Here are some common ones:
* Missing a required property – this will result in a 400 bad request. This could be a lot of things...
* ```parameters``` in an artifact are not found in the main blueprint file.
* ```policyDefinitionId``` or ```roleDefinitionId``` does not exist.
	
### Next steps
From here you will need to [publish the blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#publish-a-blueprint) and then [assign the blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#assign-a-blueprint) which you can do with either the azure portal or the rest API.

Let us know in the comments if you have any issues! 
