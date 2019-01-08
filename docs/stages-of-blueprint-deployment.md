# Stages of a blueprint deployment

When a blueprint gets deployed, there are a series of actions the blueprints service takes to deploy the resources in the blueprint. This doc goes into more specific detail about what each step involves.

## New blueprint assignment

At a high level the steps are:

1. The blueprints service is granted owner rights to the assigned subscription.
1. A user, group, or service princiapl creates a new blueprint assignment object.
1. The blueprints service creates a new system-assigned managed identity with owner rights to the assigned subscription.
1. This new system assigned managed identity is used to call ARM to deploys the artifacts in the blueprint in the specified order.
1. The managed idenity and blueprints service has their owner rights revoked.

### 1. The blueprints service is granted owner rights to the assigned subscription.

* used to create the managed identity, revoke the managed identity's access
* this granting of rights is done automatically in the UI. If doing an assignment with the REST API, you need to do this yourself with a separate API call.
* blueprints service also does **not** deploy the resources

### 2. A user/group/spn creates a new blueprint assignment object

* the object lives at the subscription scope where the blueprint is assigned
* all other resources created by the blueprint are not done by this user

### 3. The blueprints service creates a new system-assigned managed identity with owner rights to the assigned subscription.

* the managed identity represents the lifecycle of a blueprint assignment in the sense that all subsequent updates/upgrades of the same assignment reuses the same MSI.
    - The design also avoids assignments inadvertently interferring with each other.

### 4. This new system assigned managed identity deploys the artifacts in the blueprint in a specified order.

* need to understand that any access failures will relate to the access of this identity
* talk about sequencing a little bit
* link to deployment sequencing

### 5. The managed idenity and blueprints service has their owner rights revoked.
* first the managed identity has their owner access revoked
* then the blueprints service removes itself
    - in this way, we don't maintain permanent owner access to a subscription

## Updating a blueprint assignment

The stages for a blueprint assignment update are exactly the same. The managed identity already exists, so it is not recreated.


