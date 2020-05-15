To limit permissions, you need four role assignments. Two for the principal creating the deploymentScript and two for the managed identity used by the script.

For the Principal creating deployment script:
1. Custom role (deploymentScriptContributor) assigned on the sub/rg where the deployment script will be created
1. Managed Identity Operator (built-in role) on the MI used by the deployment script

For the managed identity:
1. Custom role (ACI/Storage contributor) assigned on the sub/rg where the deployment script will be created
1. Managed Identity Operator (built-in role) on the MI used by the deployment script, which seems weird because the MI principal is getting a role assignment on itself, but it works and is necessary.

If you pre-register the Storage and ACI RPs on the sub, then the roleAssignments can all exist on the RG instead of the sub.