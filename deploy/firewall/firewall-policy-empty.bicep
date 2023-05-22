param name string
@allowed([
  'Premium'
  'Standard'
])
param tier string = 'Standard'
param location string = resourceGroup().location

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: name
  location: location
  properties: {
    sku: {
      tier: tier
    }
    threatIntelMode: 'Deny'
    dnsSettings: {
      servers: []
      enableProxy: true
    }
  }
}

resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = {
  name: 'Workload'
  parent: firewallPolicy
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'Allow-Workload-Network-Rules'
        priority: 101
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
      }
      {
        name: 'Allow-Workload-Application-Rules'
        priority: 102
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
      }
    ]
  }
}

output id string = firewallPolicy.id
