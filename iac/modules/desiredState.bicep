param name string
param location string 
param baseTime string = utcNow()

var functionName = 'ServerConfiguration'
var scriptName = 'ServerConfiguration.ps1'
var bundleName = '${functionName}.zip'
var packageName = 'deploy.zip'

var sasProperties = {
    canonicalizedResource: '/blob/${storageAccount.name}/${container.name}'
    signedResourceTypes: 'sco'
    signedPermission: 'r'
    signedExpiry: dateTimeAdd(baseTime, 'PT1H')
    signedProtocol: 'https'
    signedServices: 'b'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: 'stg${replace(name,'-','')}'
}

resource service 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' existing = {
  name: 'deployment'
  parent: service
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' existing = {
  name: 'vm-${name}'
}
/*
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${name}'
  location: location
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, identity.id, roleDefinition.id)
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: roleDefinition.id
  }
}

resource bundleScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-upload-bundle'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '11.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccount.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../../dsc/ServerConfiguration.ps1')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${scriptName}; Install-Module xWebAdministration -Force; Publish-AzVMDscConfiguration ${scriptName} -ConfigurationArchivePath ${bundleName}; Set-AzStorageBlobContent -File ${bundleName} -Blob ${bundleName} -Container ${container.name} -Context (New-AzStorageContext -StorageAccountName ${storageAccount.name}) -Force -Verbose'
  }
}

resource packageScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-upload-package'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccount.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadFileAsBase64('../../package/${packageName}')
      }
    ]
    scriptContent: 'base64 -d <<< "$CONTENT" > ${packageName} && az storage blob upload -f ${packageName} -c ${container.name} -n ${packageName}'
  }
}
*/
resource dscExtension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  location: location
  parent: virtualMachine
  //dependsOn: [bundleScript]
  name: 'Microsoft.Powershell.DSC'
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: '${storageAccount.properties.primaryEndpoints.blob}${container.name}/${bundleName}' 
        script: scriptName
        function: functionName
      }
      configurationArguments: {
        siteName: 'Poc'
        applicationPool: 'Poc'
        packageUrl: '${storageAccount.properties.primaryEndpoints.blob}${container.name}/${packageName}?${storageAccount.listAccountSas('2021-04-01', sasProperties).accountSasToken}' 
        packageName: packageName
        decryptionKey: '18F665CA29B4911B0C1755979C15F40466237BC9A101836A5AC6D1CE85D6B022'
        validationKey: '1E3D5BABF386E7A89DAE461DF2FA228734680C61'
      }
    }
    protectedSettings: {
      configurationUrlSasToken: '?${storageAccount.listAccountSas('2021-04-01', sasProperties).accountSasToken}' 
    }
  }
}
