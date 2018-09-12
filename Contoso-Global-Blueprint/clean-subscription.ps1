# login to azure
Connect-AzureRmAccount

# set context to Contoso Infra1
# will need to repeat this 3 times when there are 3 subscriptions
Set-AzureRmContext -SubscriptionId "0ba674a6-9fde-43b4-8370-a7e16fdf0641"

# delete all four resource groups
Remove-AzureRmResourceGroup -Name "Networking-01" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Security-01" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Management-01" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Application-01" -Verbose -Force

# DELETE ROLE ASSIGNMENTS
# remove Contoso IT
Remove-AzureRmRoleAssignment -ObjectId "0605ea6f-1fc7-4067-bdc9-a0694a6c17b5" -RoleDefinitionName "Owner" -Scope "/subscriptions/0ba674a6-9fde-43b4-8370-a7e16fdf0641" -Verbose

# REMOVE POLICY ASSIGNMENTS AT SUB
# get all policies assigned at this sub
$policies = Get-AzureRmPolicyAssignment

# loop through returned policies and remove them
$policies | foreach {if($_.ResourceType -eq 'Microsoft.Authorization/policyAssignments') {
        Write-Host 'Removing' $_.ResourceName
        Remove-AzureRmPolicyAssignment -Name $_.ResourceName -Scope "/subscriptions/0ba674a6-9fde-43b4-8370-a7e16fdf0641"
    }
}