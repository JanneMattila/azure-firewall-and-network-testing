param name string
param location string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/21'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

var firewallSubnetId = virtualNetwork.properties.subnets[0].id

module firewall 'firewall/deploy.bicep' = {
  name: 'firewall-resources-deployment'
  params: {
    firewallSubnetId: firewallSubnetId
    location: location
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output firewallPrivateIp string = firewall.outputs.firewallPrivateIp
