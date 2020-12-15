param location string = resourceGroup().location
param csadminSshKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzDyVTIUYRsjX5SK8eH1NpgyDMUxcn5vybwKVsbyOe/JDzv+UskqdiypKwjEcgY9S+4Zc2YYIocHy2ifd1e85chVi4IdROaohRlhKqqYZ9qt/SfarjR0grEAtiN5gBHvG/mljCry78ODAHsAIRp+kqqFfrblAegw6TP3ZC9J0I1pRG9m0KEQ1PdhmuwzjL4R1qXh3HPXzCa3twGHmVLI4cS5Zo4jETm1mg+4JQNP5LfQMW9UCW5Q5MLmbl6g328zLIOpz65/MaSGDJk0eEVgFMmeIj1GMiJiyBaUTbd7HRJmb6TBje3qRx4H9pu3Ncg3Aj9QxIEPqzHVbgWJO9QJBjGVeiaPurmkx4GQwfmc+k/XrgtO7hXaXDiJKMTcXZT+3Bgk0Rr/6aLpfMW9xJkDAQNKQ4RWppkLeEmjBuEjetBFn3RHq3HE80yWtMnmW0VvhYGlION5ChMJrI/AWqXpkC1IOGorGkERb7ivAjB0LKCu9cepLRbNSO5rSQyKbdOXc= dummyKey'
param ccadminRawPassword string = '*X2changeMefnL'
param domainNameLabel string = take('cyclecloud${suffix}',14)
param myIp string = '20.49.199.4'
param suffix string = replace(guid(resourceGroup().id), '-', '')

var lockerName = take('cclocker${suffix}', 24)
var nfsName = take('ccnfs${suffix}', 24)
//var customData = '#cloud-config\n#\n# installs CycleCloud on the VM\n#\n\nyum_repos:\n  azure-cli:\n    baseurl: https://packages.microsoft.com/yumrepos/azure-cli\n    enabled: true\n    gpgcheck: true\n    gpgkey: https://packages.microsoft.com/keys/microsoft.asc\n    name: Azure CLI\n  cyclecloud:\n    baseurl: https://packages.microsoft.com/yumrepos/cyclecloud\n    enabled: true\n    gpgcheck: true\n    gpgkey: https://packages.microsoft.com/keys/microsoft.asc\n    name: Cycle Cloud\n\npackages:\n- java-1.8.0-openjdk-headless\n- azure-cli\n- cyclecloud8\n\nwrite_files:\n- content: |\n    [{\n        "AdType": "Application.Setting",\n        "Name": "cycleserver.installation.initial_user",\n        "Value": "ccadmin"\n    },\n    {\n        "AdType": "Application.Setting",\n        "Name": "cycleserver.installation.complete",\n        "Value": true\n    },\n    {\n        "AdType": "AuthenticatedUser",\n        "Name": "ccadmin",\n        "RawPassword": "${ccadminRawPassword}",\n        "Superuser": true\n    }] \n  owner: root:root\n  path: ./account_data.json\n  permissions: \'0644\'\n- content: |\n    {\n      "Name": "Azure",\n      "Environment": "public",\n      "AzureRMSubscriptionId": "${subscription().subscriptionId}",\n      "AzureRMUseManagedIdentity": true,\n      "Location": "westeurope",\n      "RMStorageAccount": "${saName}",\n      "RMStorageContainer": "cyclecloud"\n    }\n  owner: root:root\n  path: ./azure_data.json\n  permissions: \'0644\'\n\nruncmd:\n- sed -i --follow-symlinks "s/webServerPort=.*/webServerPort=80/g" /opt/cycle_server/config/cycle_server.properties\n- sed -i --follow-symlinks "s/webServerSslPort=.*/webServerSslPort=443/g" /opt/cycle_server/config/cycle_server.properties\n- sed -i --follow-symlinks "s/webServerEnableHttps=.*/webServerEnableHttps=true/g" /opt/cycle_server/config/cycle_server.properties\n- systemctl restart cycle_server\n- mv ./account_data.json /opt/cycle_server/config/data/\n- sleep 5\n- /opt/cycle_server/cycle_server execute "update Application.Setting set Value = false where name == \\"authorization.check_datastore_permissions\\""\n- unzip /opt/cycle_server/tools/cyclecloud-cli\n- ./cyclecloud-cli-installer/install.sh --system\n- sleep 60\n- /usr/local/bin/cyclecloud initialize --batch --url=https://localhost --verify-ssl=false --username="ccadmin" --password="${ccadminRawPassword}"\n- /usr/local/bin/cyclecloud account create -f ./azure_data.json'
var customData = '#cloud-config\n#\n# installs CycleCloud on the VM\n#\n\nyum_repos:\n  azure-cli:\n    baseurl: https://packages.microsoft.com/yumrepos/azure-cli\n    enabled: true\n    gpgcheck: true\n    gpgkey: https://packages.microsoft.com/keys/microsoft.asc\n    name: Azure CLI\n  cyclecloud:\n    baseurl: https://packages.microsoft.com/yumrepos/cyclecloud\n    enabled: true\n    gpgcheck: true\n    gpgkey: https://packages.microsoft.com/keys/microsoft.asc\n    name: Cycle Cloud\n\npackages:\n- java-1.8.0-openjdk-headless\n- azure-cli\n- cyclecloud8\n\nwrite_files:\n- content: |\n    [{\n        "AdType": "Application.Setting",\n        "Name": "cycleserver.installation.initial_user",\n        "Value": "ccadmin"\n    },\n    {\n        "AdType": "Application.Setting",\n        "Name": "cycleserver.installation.complete",\n        "Value": true\n    },\n    {\n        "AdType": "AuthenticatedUser",\n        "Name": "ccadmin",\n        "RawPassword": "${ccadminRawPassword}",\n        "Superuser": true\n    }] \n  owner: root:root\n  path: ./account_data.json\n  permissions: \'0644\'\n- content: |\n    {\n      "Name": "Azure",\n      "Environment": "public",\n      "AzureRMSubscriptionId": "${subscription().subscriptionId}",\n      "AzureRMUseManagedIdentity": true,\n      "Location": "westeurope",\n      "RMStorageAccount": "${lockerName}",\n      "RMStorageContainer": "cyclecloud"\n    }\n  owner: root:root\n  path: ./azure_data.json\n  permissions: \'0644\'\n\nruncmd:\n- sed -i --follow-symlinks "s/webServerPort=.*/webServerPort=80/g" /opt/cycle_server/config/cycle_server.properties\n- sed -i --follow-symlinks "s/webServerSslPort=.*/webServerSslPort=443/g" /opt/cycle_server/config/cycle_server.properties\n- sed -i --follow-symlinks "s/webServerEnableHttps=.*/webServerEnableHttps=true/g" /opt/cycle_server/config/cycle_server.properties\n- systemctl restart cycle_server\n- /opt/cycle_server/cycle_server await_startup\n- mv ./account_data.json /opt/cycle_server/config/data/\n- /opt/cycle_server/cycle_server execute "update Application.Setting set Value = false where name == \\"authorization.check_datastore_permissions\\""\n- unzip /opt/cycle_server/tools/cyclecloud-cli\n- ./cyclecloud-cli-installer/install.sh --system\n- sleep 60\n- /usr/local/bin/cyclecloud initialize --batch --url=https://localhost --verify-ssl=false --username="ccadmin" --password="${ccadminRawPassword}"\n- /usr/local/bin/cyclecloud account create -f ./azure_data.json'
var roleDefinitions = {
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'cc-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'HTTP'
        properties: {
          priority: 1010
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'HTTPS'
        properties: {
          priority: 1020
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'cc-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: 'cycleserver-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings:{
      domainNameLabel: domainNameLabel
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'cycleserver-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/Default'
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource locker 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: lockerName
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

resource nfs 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: nfsName
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
          id: '${vnet.id}/subnets/Default'
        }
      ]
      ipRules:[
        {
          value: myIp
          action:'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

/*
resource mid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'CycleCloud-MI'
  location: location
}
*/

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'cycleserver'
  location: location
  dependsOn:[
    locker
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: 'CycleServer'
      adminUsername: 'csadmin'
      customData: base64(customData)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/csadmin/.ssh/authorized_keys'
              keyData: csadminSshKey
            }
          ]
        }
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_D8s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'OpenLogic'
        offer: 'CentOS'
        sku: '8_2'
        version: 'latest'
      }
      osDisk: {
        name: 'cycleserver-os'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  properties: {
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.contributor)
    principalId: vm.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output ccFQDN string = pip.properties.dnsSettings.fqdn
