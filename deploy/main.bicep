param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'

param appName string = 'hello-dapr'

param minReplicas int = 0

param nodeImage string 
param nodePort int = 3000
var nodeServiceAppName = 'node-app'

param pythonImage string
param pythonPort int = 5000
var pythonServiceAppName = 'python-app'

param isPrivateRegistry bool = true

param containerRegistry string
@secure()
param containerRegistryUsername string = ''
@secure()
param containerRegistryPassword string = ''
#disable-next-line secure-secrets-in-params
param registryPassword string = 'registry-password'

// Container Apps Environment 
module environment 'environment.bicep' = {
  name: '${deployment().name}--environment'
  params: {
    environmentName: environmentName
    location: location
    appInsightsName: '${environmentName}-ai'
    logAnalyticsWorkspaceName: '${environmentName}-la'
  }
}

// Key Vault
module keyvault 'key-vault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    location: location
    appName: appName
    tenantId: tenant().tenantId
  }
}

// Cosmosdb
module cosmosdb 'cosmosdb.bicep' = {
  name: '${deployment().name}--cosmosdb'
  params: {
    location: location
    primaryRegion: location
    keyVaultName: keyvault.outputs.keyVaultName
  }
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvault.outputs.keyVaultName
}

// Dapr Component
module daprComponent 'dapr-component.bicep' = {
  name: '${deployment().name}--daprComponent'
  dependsOn: [
    environment
    keyvault
  ]
  params: {
    cosmosDbPrimaryMasterKey: kv.getSecret('CosmosDbPrimaryMasterKey')
    documentEndpoint: cosmosdb.outputs.documentEndpoint
    environmentName: environmentName
    pythonServiceAppName: pythonServiceAppName
  }
}

// Python App
module pythonService 'container-http.bicep' = {
  name: '${deployment().name}--${pythonServiceAppName}'
  dependsOn: [
    environment
  ]
  params: {
    enableIngress: true
    isExternalIngress: false
    location: location
    environmentName: environmentName
    containerAppName: pythonServiceAppName
    containerImage: pythonImage
    containerPort: pythonPort
    isPrivateRegistry: isPrivateRegistry 
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    registryPassword: registryPassword
    containerRegistryUsername: containerRegistryUsername
    revisionMode: 'Single'
    secrets: [
      {
        name: registryPassword
        value: containerRegistryPassword
      }
    ]
  }
}

// Node App
module nodeService 'container-http.bicep' = {
  name: '${deployment().name}--${nodeServiceAppName}'
  dependsOn: [
    environment
  ]
  params: {
    enableIngress: true 
    isExternalIngress: true
    location: location
    environmentName: environmentName
    containerAppName: nodeServiceAppName
    containerImage: nodeImage
    containerPort: nodePort
    minReplicas: minReplicas
    isPrivateRegistry: isPrivateRegistry 
    containerRegistry: containerRegistry
    registryPassword: registryPassword
    containerRegistryUsername: containerRegistryUsername
    revisionMode: 'Multiple'
    env: [
      {
        name: 'PYTHON_SERVICE_NAME'
        value: pythonServiceAppName
      }
    ]
    secrets: [
      {
        name: registryPassword
        value: containerRegistryPassword
      }
    ]
  }
}

output nodeFqdn string = nodeService.outputs.fqdn
output pythonFqdn string = pythonService.outputs.fqdn
