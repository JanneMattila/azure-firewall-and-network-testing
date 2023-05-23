param firewallPolicyId string
param ip object
param name string
param location string = resourceGroup().location

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    threatIntelMode: 'Alert'
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicyId
    }
    applicationRuleCollections: []
    natRuleCollections: []
    networkRuleCollections: []
    ipConfigurations: [
      {
        name: 'fw-pip1'
        properties: {
          subnet: {
            id: ip.subnet
          }
          publicIPAddress: {
            id: ip.publicIp
          }
        }
      }
    ]
  }
}

module diagnosticSettings 'log-analytics.bicep' = {
  name: 'firewall-diagnosticSettings-deployment'
  params: {
    name: 'diag-${firewall.name}'
    parentName: firewall.name
    location: location
  }
}

output privateIPAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
