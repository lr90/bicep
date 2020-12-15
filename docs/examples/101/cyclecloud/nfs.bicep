resource nfs 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'mynfssaaccount3414351454'
  location:  resourceGroup().location
  sku: {
    name: 'Premium_LRS'
  }
  kind:'FileStorage'
  properties: {
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass:'AzureServices'
      virtualNetworkRules:[
        {
          id: '/subscriptions/eef46e8b-63c0-478e-ae91-d074eeff48c3/resourceGroups/rg-bicep/providers/Microsoft.Network/virtualNetworks/cc-vnet/subnets/Default'
        }
      ]
      ipRules:[
        {
          value: '86.191.150.41'
          action:'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}