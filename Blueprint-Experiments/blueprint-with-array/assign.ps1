$bp = Get-AzBlueprint -ManagementGroupId ContosoRoot -Name blueprint-with-array -LatestPublished

$principals = "caeebed6-cfa8-45ff-9d8a-03dba4ef9a7d", "3adec713-6bc1-4bc6-8283-b0c71d198f90" # alfran and elkim respectively

$params = @{
    principalIds = $principals
}

$params = @{
    subnets = "{}"
}

$userAssignedPrincipalId = "/subscriptions/e4272367-5645-4c4e-9c67-3b74b59a6982/resourceGroups/Contoso/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alex-test-identity"

# subscription is contoso infra 1
New-AzBlueprintAssignment -Blueprint $bp -Name "test-arrays-with-assignment" -Location eastus -SubscriptionId "0ba674a6-9fde-43b4-8370-a7e16fdf0641" -UserAssignedIdentity $userAssignedPrincipalId -Parameter $params 