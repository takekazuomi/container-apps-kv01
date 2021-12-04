---
title: Azure Container Apps KeyVault sample project
---

## 概要

動かし方など、基本は、[こっち参照](https://github.com/takekazuomi/container-apps05)

## 背景

KeyVaultを使いたいが、App ServiceのKeyVault reference[Support for KeyVault reference syntax like in Web Aps](https://github.com/microsoft/azure-container-apps/issues/39)のようなことはできない。

Dapr component の、secret storeも使えない、[Unable to retrieve secrets from secret store (secretstores.azure.keyvault) #11](https://github.com/microsoft/azure-container-apps/issues/11)

> secretstores.azure.keyvault is currently not supported.
<https://github.com/microsoft/azure-container-apps/issues/11#issuecomment-963637326>

希望は出してあるが、答えは無い。

[Future requests: Key Vault support for secret management #7](https://github.com/microsoft/azure-container-apps/issues/7)

さらには、MSIがサポートされてない。[Support User Managed Identity for authenticating with Azure Services #16](https://github.com/microsoft/azure-container-apps/issues/16)

どの状況でもっとも簡単に使えるのは、デプロイ時にKeyVaultからシークレットを引っ張ってくる方法だろう。

つまりは、これ。↓ この方法だとリソース側のサポートは不要なので動くはず。これを検証する。

<https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets#use-a-key-vault-with-modules>

## 検証

### 1. KeyVaultをデプロイする

ちょと工夫して、シークレットをjsonにして外だししている。外だしのjson内の値を環境変数をenvsubstで置き換える。デプロイに使う、`secrets.json` は、シークレットが入るので、git ignoreしている。

```sh
make kv-deploy
```

### 2. kv無いのシークレットの参照

[main.bicep](./deploy/main.bicep) に、kv名を渡して、container.bicepにkvから引っ張ったシークレットを渡すようにする。
`containerRegistryPassword: kv.getSecret('container-secret')`の部分。

```bicep
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
```

[container.bicep](./deploy/container.bicep) では、secure stringで受け取って。

```bicep
@secure()
param containerRegistryPassword string
```

secretsに埋めるだけ。

```bicep
secrets: [
  {
    name: 'docker-password'
    value: containerRegistryPassword
  }
]
```

## まとめ

この方法では、基本的にARM Template RuntimeがKeyVaultの展開をしており、Container Appsのリソースの機能は関係なくデプロイできることが確認できた。

KeyVaultへのアクセスは、デプロイユーザーのコンテキストで行われるので、デプロイユーザーの権限が強くないといけないのがイマイチなのと、KeyVaultの変更は反映されるのは再デプロイしたときだけというの点。

参照

- <https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/key-vault-parameter?tabs=azure-cli#reference-secrets-with-static-id>
- <https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/key-vault-parameter?tabs=azure-cli#reference-secrets-with-dynamic-id>
