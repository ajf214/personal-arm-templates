$location = "eastus" # Read-Host -Prompt "Enter a location (i.e. centralus)"

$resourceGroupName = "ARM_Deploy_Staging"
# todo - this should be unique to the sub AND resource group, currently only unique to sub
$StorageAccountName = 'stage' + ((Get-AzContext).Subscription.Id).Replace('-', '').substring(0, 19)
$containerName = "templates2" # The name of the Blob container to be created.

# $fileName = "linkedStorageAccount.json" # A file name used for downloading and uploading the linked template.

# Create a resource group
$rg = Get-AzResourceGroup -Name $resourceGroupName
if (!$rg) {
  Write-Host "Creating resource group..."
  New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
  Write-Host "Resource Group $resourceGroupName already exists"
}

# Create a storage account
$stg = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
if (!$stg) {
  Write-Host "Creating storage account..."
  $stg = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName "Standard_LRS"
} else {
  Write-Host "Storage account $storageAccountName already exists"
}
$context = $stg.Context

# Create a container
$stgContainer = Get-AzStorageContainer -Name $containerName -Context $context
if (!$stgContainer) {
  Write-Host "Creating storage container..."
  New-AzStorageContainer -Name $containerName -Context $context -Permission Container
} else {
  Write-Host "Storage container $containerName already exists"
}

$filePath = "C:\Users\alfran\repos\personal-arm-templates\ARM-Templates\linked-tempalte-relPath"

# Upload the template
Write-Host "Uploading files..."
Set-AzStorageBlobContent -Container $containerName -File "$filePath\mainTemplate.json" -Blob "mainTemplate.json" -Context $context -Force
Set-AzStorageBlobContent -Container $containerName -File "$filePath\linkedTemplate.json" -Blob "linkedTemplate.json" -Context $context -Force
Write-Host "Files uploaded"