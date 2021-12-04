param environmentName string
param containerAppName string
param containerImage string
param containerPort int
param containerRegistry string
param containerRegistryUsername string
param isExternalIngress bool = true
param location string = resourceGroup().location
param minReplicas int = 0
param keyVaultNamePrefix string

var kvName = '${keyVaultNamePrefix}${uniqueString(resourceGroup().id)}'

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: kvName
}

module environment './environment.bicep' = {
  name: 'environment'
  params: {
    location: location
    environmentName: environmentName
  }
}

module httpApps 'container.bicep' = {
  name: 'httpApps'
  params: {
    location: location
    containerAppName: containerAppName
    containerImage: containerImage
    containerPort: containerPort
    containerRegistry:containerRegistry
    containerRegistryPassword: kv.getSecret('container-secret')
    containerRegistryUsername: containerRegistryUsername
    environmentId: environment.outputs.environmentId
    isExternalIngress: isExternalIngress
    minReplicas: minReplicas
  }
}
