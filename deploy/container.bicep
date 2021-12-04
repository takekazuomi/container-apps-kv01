param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param env array = []
param minReplicas int = 0

// param secrets array = [
//   {
//     name: 'docker-password'
//     value: containerRegistryPassword
//   }
// ]

@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'single'

@secure()
param containerRegistryPassword string

var cpu = json('0.25')

// The 'memory' field for each container, if provided, must contain a decimal value to
// no more than 2 decimal places followed by 'Gi' to denote the unit (Gibibytes).
// Example: '1.25Gi' or '2Gi'.
// The total requested CPU and memory resources for this application (CPU: 0.5, memory: 0.5) is invalid. Total CPU and memory for all containers defined in a Container App must add up to one of the following CPU - Memory combinations: [cpu: 0.25, memory: 0.5Gi]; [cpu: 0.5, memory: 1.0Gi]; [cpu: 0.75, memory: 1.5Gi]; [cpu: 1.0, memory: 2.0Gi]; [cpu: 1.25, memory: 2.5Gi]; [cpu: 1.5, memory: 3.0Gi]; [cpu: 1.75, memory: 3.5Gi]; [cpu: 2.0, memory: 4.0Gi]
var memory = '0.5Gi'

var registrySecretRefName = 'docker-password'

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: revisionMode
      secrets: [
        {
          name: 'docker-password'
          value: containerRegistryPassword
        }
      ]
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: registrySecretRefName
        }
      ]
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
        // traffic: [
        //   {
        //     weight: 100
        //     latestRevision: true
        //   }
        // ]
      }
    }
    template: {
      // revisionSuffix: 'somevalue'
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
          resources: {
            cpu: cpu
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 10
        rules: [
          {
            name: 'http-scale'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
      dapr: {
        enabled: false
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
