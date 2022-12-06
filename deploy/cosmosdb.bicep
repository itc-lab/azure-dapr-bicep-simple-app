@description('Cosmos DB アカウント名、最大長 44 文字、小文字')
param accountName string = 'cosmos-${uniqueString(resourceGroup().id)}'

@description('Cosmos DB アカウントのロケーション')
param location string

@description('Cosmos DB アカウントのプライマリ レプリカ リージョン')
param primaryRegion string

@description('Cosmos DB アカウントの既定の整合性レベル')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string = 'Session'

@description('古いリクエストの最大数。BoundedStaleness（有界整合性制約）に必要です。有効な範囲、シングル リージョン: 10 ～ 1000000。マルチ リージョン: 100000 ～ 1000000。')
@minValue(10)
@maxValue(2147483647)
param maxStalenessPrefix int = 100000

@description('最大遅延時間 (分)。BoundedStaleness（有界整合性制約）に必要です。有効な範囲、シングル リージョン: 5 ～ 84600。マルチ リージョン: 300 ～ 86400。')
@minValue(5)
@maxValue(86400)
param maxIntervalInSeconds int = 300

@description('データベースの名前')
param databaseName string = 'ordersDb'

@description('コンテナの名前')
param containerName string = 'orders'

@description('Maximum throughput for the container')
@minValue(4000)
@maxValue(1000000)
param autoscaleMaxThroughput int = 4000

param keyVaultName string

var accountNameVar = toLower(accountName)
var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}
var locations = [
  {
    locationName: primaryRegion
    // フェールオーバー優先度
    failoverPriority: 0
    // ゾーン冗長
    isZoneRedundant: false
  }
]

resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-01-15' = {
  name: accountNameVar
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
  }
}

resource accountName_databaseName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-01-15' = {
  parent: accountName_resource
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource accountName_databaseName_containerName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-01-15' = {
  parent: accountName_databaseName
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/partitionKey'
        ]
        kind: 'Hash'
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: autoscaleMaxThroughput
      }
    }
  }
}

module setCosmosDbPrimaryMasterKey 'key-vault-secret.bicep' = {
  name: 'setCosmosDbPrimaryMasterKey'
  params: {
    keyVaultName: keyVaultName
    secretName: 'CosmosDbPrimaryMasterKey'
    secretValue: listKeys(accountName_resource.id, accountName_resource.apiVersion).primaryMasterKey
  }
}

output documentEndpoint string = accountName_resource.properties.documentEndpoint
