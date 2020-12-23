$ErrorActionPreference = "Stop"

$location = "eastus"
$resourceGroupName = "ARM_Deploy_Staging"

# todo - this should be unique to the sub AND resource group, currently only unique to sub
$StorageAccountName = 'stage' + ((Get-AzContext).Subscription.Id).Replace('-', '').substring(0, 19)
$containerName = "template-staging" # container must be 3-63 characters, all

# Create a resource group
$rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (!$rg) {
  Write-Host "Creating resource group..."
  New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
  Write-Host "Resource Group $resourceGroupName already exists"
}

# Create a storage account
$stg = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
if (!$stg) {
  Write-Host "Creating storage account..."
  $stg = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName "Standard_LRS"
} else {
  Write-Host "Storage account $storageAccountName already exists"
}
$context = $stg.Context

# Create a container
$stgContainer = Get-AzStorageContainer -Name $containerName -Context $context -ErrorAction SilentlyContinue
if (!$stgContainer) {
  Write-Host "Creating storage container..."
  New-AzStorageContainer -Name $containerName -Context $context 
} else {
  Write-Host "Storage container $containerName already exists"
}

$filePath = "C:\Users\alfran\repos\personal-arm-templates\ARM-Templates\testing\linked-template-relPath"

# Upload the template
Write-Host "Uploading files..."
Set-AzStorageBlobContent -Container $containerName -File "$filePath\mainTemplate.json" -Blob "mainTemplate.json" -Context $context -Force
Set-AzStorageBlobContent -Container $containerName -File "$filePath\linkedTemplate.json" -Blob "linkedTemplate.json" -Context $context -Force
Write-Host "Files uploaded"

# construct root templateUri for deployment
$templateUri = $stg.Context.BlobEndPoint + "$containerName/mainTemplate.json"

# Generate sasUri
$sasToken = New-AzStorageContainerSASToken -Container $containerName -Context $stg.Context -Permission r -ExpiryTime (Get-Date).AddHours(4)

# strip off leading '?' because ARM backend will add it automatically, which might be an issue
$newSas = $sasToken.substring(1)

Write-Host "Attempting deployment with following URI: "
Write-Host "$templateUri$sasToken" # using original $sasToken since it has the leading '?' for the purpose of emitting a debuggin URL
New-AzResourceGroupDeployment -ResourceGroupName "brittle-hollow" -TemplateUri $templateUri -QueryString $newSas -Verbose
