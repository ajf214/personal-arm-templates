$myBluerpint = Get-AzBlueprint -ManagementGroupId ContosoRoot -Name "deep-dive-01" -Version "1.4"
$subId = "35ad74f4-0b37-44a7-ba94-91b6ec6026cd"

$rgHash = @{ name="my-ps-rg"; location = "eastus" }

$rgArray = @{ Networking = $rgHash }

New-AzBlueprintAssignment -Blueprint $myBluerpint -Location eastus -SubscriptionId $subId -ResourceGroupParameter $rgArray