# Get blob endpoint for base template
$stg = Get-AzStorageAccount -ResourceGroupName "ARM_Deploy_Staging"
$containerName = "templates2"
$templateUri = $stg.Context.BlobEndPoint + "$containerName/mainTemplate.json"

# Generate sasUri
$sasToken = New-AzStorageContainerSASToken -Container $containerName -Context $stg.Context -Permission r -ExpiryTime (Get-Date).AddHours(4)

# strip off leading '?' because ARM backend will add it automatically, which might be an issue
$newSas = $sasToken.substring(1)

Write-Host "Attempting deployment with following URI: "
Write-Host "$templateUri$newSas"
New-AzResourceGroupDeployment -ResourceGroupName "brittle-hollow" -TemplateUri $templateUri -QueryString $newSas -Verbose
