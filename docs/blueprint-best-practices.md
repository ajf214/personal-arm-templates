*this is obviously not complete*

# Blueprint definition and assignment best practices

Considerations:
* what defines an environment for an application time?
* is your application boundary a resource group, subscription, or management group?


## Blueprint to deploy a whole environment

Considerations:
* Separation of concerns is always a good thing, so if you have a blueprint manage an entire environment it should be because there is one time in the org responsible for that blueprint
* More common in SMBs for the above reason 

## Blueprint to deploy a component in your environment

Considerations:
* As organizations scale up, they will have separate teams managing more complex environments
* This lends itself to blueprints that represent key components in an environment.
    - for example, you may have a dedicated networking blueprint or dedicated backup/recovery blueprint, etc.

## Shared subscriptions
Considerations:
* Be aware of [subscription limits](http://google.com)
* Subscription level uniqueness
    - Many properties (resource IDs, IP address, etc.) must be unique to a subscription
* In many orgs, it's common for an application team to share a subscription with other app teams. In this case, you will definte a blueprint that targets a resource group or set of resource groups. It will still be assigned to a subscription, but it will only manage a subset of that subscription.
    - A single blueprint definition can be assigned to the subscription as many times as you need. 

## Dedicated subscriptions

Considerations: 
* This is the core use case that blueprints. In a large organization that has adopted management groups, the blueprints will be saved here and then applied to a new subscription to stand up a new environment.
* There are two main "dedicated subscription" scenarios:
    - Subscription for an entire application. Dev/Test/Prod environments are all in a single subscriptiption
    - Subscription for an environment "type". This is the recommended Microsoft best practice for large organizations because it gives you room to scale. Dev/Test/Prod each have their **own** subscription

## Parameterization
Considerations:
* Blueprints should take advantage of parameters wherever possible to increase the flexibility of the blueprint
* Be careful not to *over-parameterize* as this may be overwhelming to the user assigning the blueprint
* Take advantage of `defaultValues` and `allowedValues` to make assigning the blueprint even easier.
* With the API you can create "global" blueprint parameters that you can use in any artifact. Useful if you want to set a tag or specific region on all resources/artifacts in a blueprint. 
* Full doc on blueprint parameters is [here](https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/parameters)