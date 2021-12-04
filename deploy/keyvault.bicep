param prefix string
param location string = resourceGroup().location
param objectId string

@description(' {"name":"","value":""} wrapped in a secure object.')
var secrets = json(loadTextContent('./secrets.json'))

var kvName = '${prefix}${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: kvName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for o in secrets: {
  name: o.name
  parent: keyVault
  properties: {
    value: o.value
  }
}]
