# SUBSCRIPTIONS
# Contoso IT - Retail - Prod: 45f9252d-e27e-4ed8-ab4e-dc5054de13fa
# Contoso IT - Retail - Pre-Prod: 210b13f9-e96d-493c-919e-34e12038a338 
# Contoso IT - Retail - DevTest: 35ad74f4-0b37-44a7-ba94-91b6ec6026cd

# login to azure
Connect-AzureRmAccount
$subscriptionId = "35ad74f4-0b37-44a7-ba94-91b6ec6026cd"

# set context to Contoso Infra1
# will need to repeat this 3 times when there are 3 subscriptions
Set-AzureRmContext -SubscriptionId $subscriptionId

# delete all four resource groups
Remove-AzureRmResourceGroup -Name "Networking-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Security-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Management-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Application-resource-group" -Verbose -Force

# DELETE ROLE ASSIGNMENTS
# remove Contoso IT
Remove-AzureRmRoleAssignment -ObjectId "0605ea6f-1fc7-4067-bdc9-a0694a6c17b5" -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscriptionId" -Verbose

# REMOVE POLICY ASSIGNMENTS AT SUB
# get all policies assigned at this sub
$policies = Get-AzureRmPolicyAssignment

# loop through returned policies and remove them
$policies | foreach {if($_.ResourceType -eq 'Microsoft.Authorization/policyAssignments') {
        Write-Host 'Removing' $_.ResourceName
        Remove-AzureRmPolicyAssignment -Name $_.ResourceName -Scope "/subscriptions/$subscriptionId"
    }
}