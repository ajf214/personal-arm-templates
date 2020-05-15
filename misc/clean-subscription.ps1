# should get context so it can be reset at the end of exectuion

$subcriptionId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # Contoso IT – SH360 – Prod

# switch to selected subscription
Set-AzContext -SubscriptionId $subcriptionId

# remove all blueprint assignments
$bps = Get-AzBlueprintAssignment -SubscriptionId $subcriptionId
foreach ($bp in $bps) {
    $temp = "Deleting blueprint assignment {0}" -f $bp.Name
    Write-Host $temp
    Remove-AzBlueprintAssignment -Name $bp.Name
}

# somehow get a new auth token??
# this will be required if locks were added in the assignment
# todo

# todo - removed resource locks that that ISO shared services blueprint is adding

# get all rgs
$rgs = Get-AzResourceGroup

# loop through each rg in a sub
foreach ($rg in $rgs) {
    $temp = "Deleting {0}..." -f $rg.ResourceGroupName
    Write-Host $temp
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force # delete the current rg
    # some output on a good result
}

$policies = Get-AzPolicyAssignment

foreach ($policy in $policies) {
    $temp = "Removing policy assignment: {0}" -f $policy.Name
    Write-Host $temp
    Remove-AzPolicyAssignment -ResourceId $policy.ResourceId # TODO - also print display name..
}

# get-azroleassignment returns assignments at current OR parent scope`
# will need to do a check on the scope property
$rbacs = Get-AzRoleAssignment 

foreach ($rbac in $rbacs) {
    if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
        Write-Output "Found a role assignment to delete"
        Remove-AzRoleAssignment -InputObject $rbac
    } else {
        $temp = "NOT deleting role with scope {0}" -f $rbac.Scope
    }
}

