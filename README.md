# azure-dapr-bicep-simple-app

![deploy_overview](https://user-images.githubusercontent.com/76575923/207849499-5d0c3f24-519a-46f0-bdf1-178289e06557.png)

## Overview

Azure Container Apps ＋ Dapr へ GitHub Actions, Bicep, Azure Container Registry を使ってデプロイの Example です。  
Azure にデプロイしない場合、Dapr CLI を使ってローカル環境で動作確認できます。  
アプリの動作は単純です。固定の JSON を Dapr を通して、DB に対し、Post(Create)、Get(Read)、Delete を行います。  

![app_overview](https://user-images.githubusercontent.com/76575923/207849527-fb117ec8-9b3c-4e61-a030-9ac5c430541a.png)

DB は、GitHub Actions と Bicep を使って、Azure にデプロイするときは、Cosmos DB です。  
ローカル開発の時は、Dapr CLI から Redis を使用します。

GitHub Actions の deploy ジョブで作成されるリソースは、以下です。  
全て同じリソースに作成されます。  
・Azure LogAnalytics  
・Azure Application Insights  
・Azure Key Vault  
・Azure Cosmos DB  
・Azure Container Apps の環境  
・Azure Container Apps のアプリ

詳細な手順は、こちらのブログ記事に書きました。（外部リンクです。）  
[Bicep を使って Azure Container Apps と Dapr のマイクロサービスをデプロイ](https://itc-engineering-blog.netlify.app/blogs/azure-aca-dapr-bicep)

This is an example of deploying to Azure Container Apps using bicep, Azure Container Registry, and GitHub Actions.  
If you do not deploy to Azure, you can setup in the local environment using Dapr CLI.  
How the app works is simple. Post (Create), Get (Read), and Delete fixed JSON to DB through Dapr.

![app_overview](https://user-images.githubusercontent.com/76575923/207849527-fb117ec8-9b3c-4e61-a030-9ac5c430541a.png)

The DB is Cosmos DB when deployed to Azure using GitHub Actions and Bicep.  
For local development, use Redis from the Dapr CLI.

The resources created by the GitHub Actions deploy job are:  
・Log analysis workspace  
・Application Insights  
・Azure Key Vault  
・Azure Cosmos DB  
・Azure Container Apps environment  
・Azure Container Apps  
All created in the same resource.

For detailed instructions, check out this blog post. (External link, In Japanese)  
[Deploying Azure Container Apps and Dapr microservices using Bicep](https://itc-engineering-blog.netlify.app/blogs/azure-aca-dapr-bicep)

## Requirement

* npm  
* pip3  
* python3

## Getting Started

1. Install Dapr CLI

```sh
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
dapr init
```

2. Clone the repo

```sh
git clone https://github.com/itc-lab/azure-dapr-bicep-simple-app
```

3. Install NPM packages

```sh
cd azure-dapr-bicep-simple-app/node-service
npm install
```

4. build React client

```sh
npm run buildclient
```

5. Install Python packages

```sh
cd ../python-service
pip3 install -r requirements.txt
```

6. Run with Dapr

```sh
$ cd ../
$ cd python-service
$ dapr run --app-id python-app --app-port 5000 --dapr-http-port 3500 --components-path ../dapr-components/local python3 app.py
$ cd ../
$ cd node-service
$ dapr run --app-id node-app --app-port 3000 --dapr-http-port 3501 npm start
```

7. open `http://localhost:3000`
