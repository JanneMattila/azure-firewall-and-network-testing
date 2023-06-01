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
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Kubernetes operations against the Azure API'
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
              'management.azure.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Microsoft packages repository access'
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
              'packages.microsoft.com'
              'acs-mirror.azureedge.net'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Linux OS updates'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#optional-recommended-fqdn--application-rules-for-aks-clusters'
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
              'security.ubuntu.com'
              'azure.archive.ubuntu.com'
              'changelogs.ubuntu.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow GPU enabled access'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#gpu-enabled-aks-clusters-required-fqdn--application-rules'
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
              'nvidia.github.io'
              'us.download.nvidia.com'
              'download.docker.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Windows Server based node pools https'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#gpu-enabled-aks-clusters-required-fqdn--application-rules'
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
              'onegetcdn.azureedge.net'
              'go.microsoft.com'
              'download.docker.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Windows Server based node pools http'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#gpu-enabled-aks-clusters-required-fqdn--application-rules'
            sourceAddresses: [
              '*'
            ]
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
            ]
            targetFqdns: [
              '*.mp.microsoft.com'
              'www.msftconnecttest.com'
              'ctldl.windowsupdate.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Microsoft Defender for Containers'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#microsoft-defender-for-containers'
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
              '*.ods.opinsights.azure.com'
              '*.oms.opinsights.azure.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow CSI Secret Store'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#csi-secret-store'
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
              'vault.azure.net'
              #disable-next-line no-hardcoded-env-urls
              '*.vault.azure.net'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Azure Monitor for containers'
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
            name: 'Allow Azure Policy'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-policy'
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
              'data.policy.core.windows.net'
              #disable-next-line no-hardcoded-env-urls
              'store.policy.core.windows.net'
              'dc.services.visualstudio.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow Cluster extensions'
            description: 'For more details see: https://aka.ms/aks-required-ports-and-addresses and https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#cluster-extensions'
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
              '*..dp.kubernetesconfiguration.azure.com'
              'arcmktplaceprod.azurecr.io'
              '*.ingestion.msftcloudes.com'
              '*.microsoftmetrics.com'
              'marketplaceapi.microsoft.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow container images from Docker Hub'
            description: 'Docker Images are fetched from address which look like this: registry-1.docker.io'
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
              '*.docker.io'
            ]
          }
        ]
      }
    ]
  }
}

output id string = firewallPolicy.id
