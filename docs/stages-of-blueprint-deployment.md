# Stages of a blueprint deployment

When a blueprint gets deployed, there are a series of actions the blueprints service takes to deploy the resources in the blueprint. This doc goes into more specific detail about what each step involves.

## New blueprint assignment

At a high level the steps are:

1. A user, group, or service princiapl creates a new blueprint assignment object.
1. The blueprints service is granted owner rights to the assigned subscription. 
1. The blueprints service creates a new system-assigned managed identity with owner rights to the assigned subscription.
1. This new system assigned managed identity deploys the artifacts in the blueprint in a specified order.
1. The managed idenity and blueprints service has their owner rights revoked.

### 1. A user creates a new blueprint assignment object

* the object living at the subscription scope
* all other resources created by the blueprint are not done by this user

### 2. The blueprints service is granted owner rights to the assigned subscription.

* only used to create the managed identity
* blueprints service also does **not** deploy the resources
* this granting of rights is done automatically in the UI. If doing an assignment with the REST API, you need to do this yourself with a separate API call.

### 3. The blueprints service creates a new system-assigned managed identity with owner rights to the assigned subscription.

* justify why the managed identity is important here
    - talk about isolation, etc. 

### 4. This new system assigned managed identity deploys the artifacts in the blueprint in a specified order.

* need to understand that any access failures will relate to the access of this identity
* talk about sequencing a little bit

### 5. The managed idenity and blueprints service has their owner rights revoked.

* explain why we revoke access
* how this works with an update

## Updating a blueprint assignment

### 1. User updates the blueprint assignment object

* can choose to use a new version
* any new parameters will update the object

### 2. Blueprints service and managed identity are re-granted owner access

* not sure what details are need here...

### 3. Managed identity deploys all artifacts, including updates or changes

* the managed identity performs all the operations as if it were a create
* rbac and policy are done by the blueprint service. You can learn more about how we process artifact updates [here](link to this doc)
* updates are handled entirely by the RP, it should predictably operate as if the object was updated outside of the assignment

### 4. The managed idenity and blueprints service has their owner rights revoked.

* same as above


