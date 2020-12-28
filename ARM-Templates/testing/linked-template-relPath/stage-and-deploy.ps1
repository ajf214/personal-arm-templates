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
  $stgContainer = New-AzStorageContainer -Name $containerName -Context $context 
} else {
  Write-Host "Storage container $containerName already exists"
}

$folderRoot = "C:\Users\alfran\repos\personal-arm-templates\ARM-Templates\testing\linked-template-relPath"

# Upload the template
Write-Host "Uploading files..."

$filesToUpload = Get-ChildItem $folderRoot -Recurse -File

foreach ($file in $filesToUpload) {
  Write-Host $file
  $targetPath = ($file.fullname.Substring($folderRoot.Length + 1)).Replace("\", "/")
  Write-Host "Uploading $("\" + $file.fullname.Substring($folderRoot.Length + 1)) to $($stgContainer.CloudBlobContainer.Uri.AbsoluteUri + "/" + $targetPath)"
  Set-AzStorageBlobContent -File $file.fullname -Container $stgContainer.Name -Blob $targetPath -Context $context -Force # | Out-Null
}

Write-Host "Files uploaded"

Write-Host "Start deployment at following location:"

$deploy = $true

if ($deploy) {
  # construct root templateUri for deployment
  $templateUri = $stg.Context.BlobEndPoint + "$containerName/mainTemplate.json"

  # Generate sasUri
  $sasToken = New-AzStorageContainerSASToken -Container $containerName -Context $stg.Context -Permission r -ExpiryTime (Get-Date).AddHours(4)

  # strip off leading '?' because ARM backend will add it automatically, which might be an issue
  $newSas = $sasToken.substring(1)

  Write-Host "Attempting deployment with following URI: "
  Write-Host "$templateUri$sasToken" # using original $sasToken since it has the leading '?' for the purpose of emitting a debuggin URL
  
  New-AzResourceGroupDeployment -ResourceGroupName "brittle-hollow" -TemplateUri $templateUri -QueryString $newSas -Verbose
}
