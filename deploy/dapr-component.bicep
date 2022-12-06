param environmentName string
param documentEndpoint string
param pythonServiceAppName string

@secure()
param cosmosDbPrimaryMasterKey string = ''

resource stateDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: '${environmentName}/orders'
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    secrets: [
      {
        name: 'masterkey'
        value: cosmosDbPrimaryMasterKey
      }
    ]
    metadata: [
      {
        name: 'url'
        value: documentEndpoint
      }
      {
        name: 'database'
        value: 'ordersDb'
      }
      {
        name: 'collection'
        value: 'orders'
      }
      {
        name: 'masterkey'
        secretRef: 'masterkey'
      }
    ]
    scopes: [
      pythonServiceAppName
    ]
  }
}
