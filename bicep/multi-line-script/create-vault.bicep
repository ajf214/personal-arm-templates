param accessPolicies array = [
  {
    tenantId: subscription().tenantId
    objectId: 'caeebed6-cfa8-45ff-9d8a-03dba4ef9a7d' // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
    }
  }
]

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'adotfrank-kv'
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: accessPolicies
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    networkAcls: {
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: 'alex-test-deny'
  scope: resourceGroup('210b13f9-e96d-493c-919e-34e12038a338', 'managed-identities')
}

resource ds 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  name: 'create-cert'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.4.0'
    retentionInterval: 'P1D'
    arguments: '-vaultName ${kv.name} -certName foo -subjectName foo'
    scriptContent: '''
param(
  [string] [Parameter(Mandatory=$true)] $vaultName,
  [string] [Parameter(Mandatory=$true)] $certificateName,
  [string] [Parameter(Mandatory=$true)] $subjectName
)

$ErrorActionPreference = 'Stop'
$DeploymentScriptOutputs = @{}

$existingCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

if ($existingCert -and $existingCert.Certificate.Subject -eq $subjectName) {

  Write-Host 'Certificate $certificateName in vault $vaultName is already present.'

  $DeploymentScriptOutputs['certThumbprint'] = $existingCert.Thumbprint
  $existingCert | Out-String
}
else {
  $policy = New-AzKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose

  # private key is added as a secret that can be retrieved in the Resource Manager template
  Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose

  $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

  # it takes a few seconds for KeyVault to finish
  $tries = 0
  do {
    Write-Host 'Waiting for certificate creation completion...'
    Start-Sleep -Seconds 10
    $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
    $tries++

    if ($operation.Status -eq 'failed')
    {
      throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
    }

    if ($tries -gt 120)
    {
      throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
    }
  } while ($operation.Status -ne 'completed')

  $DeploymentScriptOutputs['certThumbprint'] = $newCert.Thumbprint
  $newCert | Out-String
}
'''
  }
}