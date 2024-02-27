param name string
param location string 
param version string = ''
param decryptionKey string
param validationKey string
param baseTime string = utcNow()

var functionName = 'ServerConfiguration'
var scriptName = 'ServerConfiguration.ps1'
var bundleName = '${functionName}${empty(version) ? '' : '-v'}${version}.zip'
var packageName = 'WebDeploy${empty(version) ? '' : '-v'}${version}.zip'

var sasProperties = {
    canonicalizedResource: '/blob/${storageAccount.name}'
    signedResourceTypes: 'sco'
    signedPermission: 'rl'
    signedExpiry: dateTimeAdd(baseTime, 'PT1H')
    signedProtocol: 'https'
    signedServices: 'b'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: 'stg${replace(name,'-','')}'
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: 'default'
  parent: storageAccount
}

resource deployContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' existing = {
  name: 'deployments'
  parent: blobService
}

resource configContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' existing = {
  name: 'configurations'
  parent: blobService
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' existing = {
  name: 'vm-${name}'
}

resource dscExtension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  location: location
  parent: virtualMachine
  name: 'Microsoft.Powershell.DSC'
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: '${storageAccount.properties.primaryEndpoints.blob}${configContainer.name}/${bundleName}' 
        script: scriptName
        function: functionName
      }
      configurationArguments: {
        siteName: 'Poc'
        applicationPool: 'Poc'
        packageUrl: '${storageAccount.properties.primaryEndpoints.blob}${deployContainer.name}/${packageName}?${storageAccount.listAccountSas('2021-04-01', sasProperties).accountSasToken}' 
        packageName: packageName
        decryptionKey: decryptionKey
        validationKey: validationKey
      }
    }
    protectedSettings: {
      configurationUrlSasToken: '?${storageAccount.listAccountSas('2021-04-01', sasProperties).accountSasToken}' 
    }
  }
}
