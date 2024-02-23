param name string
param location string
param kind string = 'StorageV2'
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'stg${replace(name,'-','')}'
  location: location
  kind: kind
  sku: {
    name: sku
  }
}
