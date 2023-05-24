param name string = 'afwp-hub'
param location string = resourceGroup().location

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: name
  location: location
  properties: {
    sku: {
      tier: 'Standard'
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
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow container images from mcr.microsoft.com'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-fqdn--application-rules'
            sourceAddresses: [
              '*'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              'mcr.microsoft.com'
              '*.data.mcr.microsoft.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow monitoring'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-monitor-for-containers'
            sourceAddresses: [
              '*'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              'dc.services.visualstudio.com'
              '*.ods.opinsights.azure.com'
              '*.oms.opinsights.azure.com'
              '*.monitoring.azure.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Azure Active Directory authentication'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-fqdn--application-rules'
            sourceAddresses: [
              '*'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              #disable-next-line no-hardcoded-env-urls
              'login.microsoftonline.com'
            ]
          }
        ]
      }
    ]
  }
}

output id string = firewallPolicy.id
