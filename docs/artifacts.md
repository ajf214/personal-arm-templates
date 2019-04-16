---
title: Azure Blueprints functions
description: Describes the functions for use with Azure Blueprints definitions and assignments.
services: blueprints
author: DCtheGeek
ms.author: dacoulte
ms.date: 03/31/2019
ms.topic: reference
ms.service: blueprints
manager: carmonm
---
# Functions for use with Azure Blueprints

Azure Blueprints provides functions making a blueprint definition more dynamic. These functions are
for use with blueprint definitions and blueprint artifacts. A Resource Manager Template artifact
supports the full use of Resource Manager functions in addition to getting a dynamic value through a
blueprint parameter.

The following functions are supported:

- [artifacts](#artifacts)
- [concat](#concat)
- [parameters](#parameters)
- [resourceGroup](#resourcegroup)
- [resourceGroups](#resourcegroups)
- [subscription](#subscription)

## artifacts

`artifacts(artifactName)`

Returns an object of properties populated with that blueprint artifacts outputs.

### Parameters

| Parameter | Required | Type | Description |
|:--- |:--- |:--- |:--- |
| artifactName |Yes |string |The name of a blueprint artifact. |

### Return value

An object of output properties. The output properties are dependent on the type of blueprint
artifact being referenced. All types follow the format:

```json
{
  "output": {collectionOfOutputProperties}
}
```

#### Policy assignment artifact

```json
{
    "output": {
        "policyAssignmentId": "{resourceId-of-policy-assignment}",
        "policyAssignmentName": "{name-of-policy-assignment}",
        "policyDefinitionId": "{resourceId-of-policy-definition}",
    }
}
```

#### Resource Manager template artifact

The **output** properties of the returned object are defined within the Resource Manager template
and returned by the deployment.

#### Role assignment artifact

```json
{
    "output": {
        "roleAssignmentId": "{resourceId-of-role-assignment}",
        "roleDefinitionId": "{resourceId-of-role-definition}",
        "principalId": "{principalId-role-is-being-assigned-to}",
    }
}
```

### Example

A Resource Manager template artifact with the ID _myTemplateArtifact_ containing the following
sample output property:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    ...
    "outputs": {
        "myArray": {
            "type": "array",
            "value": ["first", "second"]
        },
        "myString": {
            "type": "string",
            "value": "my string value"
        },
        "myObject": {
            "type": "object",
            "value": {
                "myProperty": "my value",
                "anotherProperty": true
            }
        }
    }
}
```

Some examples of retrieving data from the _myTemplateArtifact_ sample are:

| Expression | Type | Value |
|:---|:---|:---|
|`[artifacts("myTemplateArtifact").output.myArray]` | Array | \["first", "second"\] |
|`[artifacts("myTemplateArtifact").output.myArray[0]]` | String | "first" |
|`[artifacts("myTemplateArtifact").output.myString]` | String | "my string value" |
|`[artifacts("myTemplateArtifact").output.myObject]` | Object | { "myproperty": "my value", "anotherProperty": true } |
|`[artifacts("myTemplateArtifact").output.myObject.myProperty]` | String | "my value" |
|`[artifacts("myTemplateArtifact").output.myObject.anotherProperty]` | Bool | True |

## concat

`concat(string1, string2, string3, ...)`

Combines multiple string values and returns the concatenated string.

### Parameters

| Parameter | Required | Type | Description |
|:--- |:--- |:--- |:--- |
| string1 |Yes |string |The first value for concatenation. |
| additional arguments |No |string |Additional values in sequential order for concatenation |

### Return value

A string of concatenated values.

### Remarks

The Azure Blueprint function differs from the Azure Resource Manager template function in that it
only works with strings.

### Example

`concat(parameters('organizationName'), '-vm')`

## parameters

`parameters(parameterName)`

Returns a blueprint parameter value. The specified parameter name must be defined in the blueprint
definition or in blueprint artifacts.

### Parameters

| Parameter | Required | Type | Description |
|:--- |:--- |:--- |:--- |
| parameterName |Yes |string |The name of the parameter to return. |

### Return value

The value of the specified blueprint or blueprint artifact parameter.

### Remarks

The Azure Blueprint function differs from the Azure Resource Manager template function in that it
only works with blueprint parameters.

### Example

In your blueprint PUT body:

```json
{
    "type": "Microsoft.Blueprint/blueprints",
    "properties": {
        ...
        "parameters": { 
            "principalIds": {
                "type": "string", 
                "metadata": {
                    "displayName": "Principal IDs",
                    "description": "This is a blueprint parameter that any artifact can reference. We'll display these descriptions for you in the info bubble. Supply principal IDs for the users, groups or service principals for the RBAC assignment",
                    "strongType": "PrincipalId"
                }
            }
        },
        ...
    }
}
```

In an artifact PUT body:

```json
{
    "type": "Microsoft.Blueprint/blueprints/artifacts",
    "kind": "roleAssignment",
    ...
    "properties": {
        "roleDefinitionId": "/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635",
        "principalIds": ["[parameters('principalIds')]"],
        ...
    }
}
```

## resourceGroup

`resourceGroup()`

Returns an object that represents the current resource group.

### Return value

The returned object is in the following format:

```json
{
  "name": "{resourceGroupName}",
  "location": "{resourceGroupLocation}",
}
```

### Remarks

The Azure Blueprint function differs from the Azure Resource Manager template function. The
`resourceGroup()` function can't be used in a subscription level artifact or the blueprint
definition. It can only be used in blueprint artifacts that are part of a resource group artifact.

A common use of the `resourceGroup()` function is to create resources in the same location as the
resource group artifact.

### Example

If we want to use the resourceGroup's location (whether it is determined at definition or assignment time) as the locaiton for a resource in a template artifact:

You can declare a resource group placeholder object in your blueprint PUT:

```json
{
    "type": "Microsoft.Blueprint/blueprints",
    "properties": {
        ...
        "resourceGroups": {
            "NetworkingPlaceholder": {
                "location": "eastus"
            }
        }
    }
}
```

In order to use the `resourceGroup` function we need to be in the context of an artifact that is targeting a resourceGroup placeholder object, like this:

```json
{
  "type": "Microsoft.Blueprint/blueprints/artifacts",
  "kind": "template",
  "properties": {
      "template": {
        ...
      },
      "resourceGroup": "NetworkingPlaceholder",
      ...
      "parameters": {
        "resourceLocation": {
          "value": "[resourceGroup().location]"
        }
      }
  }
}
```

## resourceGroups

`resourceGroups(placeholderName)`

Returns an object that represents the specified resource group artifact. This is useful if you need to get the properties of a specific resourceGroup placeholder, even if you are not necessarily in the context of an artifact that targets that resourceGroup.

### Parameters

| Parameter | Required | Type | Description |
|:--- |:--- |:--- |:--- |
| placeholderName |Yes |string |The placeholder name of the resource group artifact to return. |

### Return value

The returned object is in the following format:

```json
{
  "name": "{resourceGroupName}",
  "location": "{resourceGroupLocation}",
}
```

### Example

You can declare a resource group placeholder object in your blueprint PUT:

```json
{
    "type": "Microsoft.Blueprint/blueprints",
    "properties": {
        ...
        "resourceGroups": {
            "NetworkingPlaceholder": {
                "location": "eastus"
            }
        }
    }
}
```

Then you can pass use this resource group placeholder value in any artifact PUT:

```json
{
  "kind": "template",
  "properties": {
      "template": {
          ...
      },
      ...
      "parameters": {
        "artifactLocation": {
          "value": "[resourceGroups('NetworkingPlaceholder').location]"
        }
      }
  },
  "type": "Microsoft.Blueprint/blueprints/artifacts",
  "name": "myTemplate"
}
```

## subscription

`subscription()`

Returns details about the subscription for the current blueprint assignment.

### Return value

The returned object is in the following format:

```json
{
    "id": "/subscriptions/{subscriptionId}",
    "subscriptionId": "{subscriptionId}",
    "tenantId": "{tenantId}",
    "displayName": "{name-of-subscription}"
}
```

### Example

You may want to use the subscription name and use the `concat()` function to create a naming convention:

```json
{
  "kind": "template",
  "properties": {
      "template": {
          ...
      },
      ...
      "parameters": {
        "resourceName": {
          "value": "[concat(subscription().displayName, '-vm')]"
        }
      }
  },
  "type": "Microsoft.Blueprint/blueprints/artifacts",
  "name": "myTemplate"
}
```

## Next steps

- Learn about the [blueprint life-cycle](../concepts/lifecycle.md).
- Understand how to use [static and dynamic parameters](../concepts/parameters.md).
- Learn to customize the [blueprint sequencing order](../concepts/sequencing-order.md).
- Find out how to make use of [blueprint resource locking](../concepts/resource-locking.md).
- Learn how to [update existing assignments](../how-to/update-existing-assignments.md).
- Resolve issues during the assignment of a blueprint with [general troubleshooting](../troubleshoot/general.md).