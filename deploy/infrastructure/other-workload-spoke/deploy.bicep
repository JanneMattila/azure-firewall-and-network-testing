param spokeName string
param addressSpacePrefix string
param hubName string
param hubId string
param firewallIpAddress string
param location string = resourceGroup().location

var vnetName = 'vnet-${spokeName}'

var vnetAddressSpace = '${addressSpacePrefix}.0.0/16'

resource spokeRouteTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'rt-${spokeName}-front'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'All'
        properties: {
          addressPrefix: vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  tags: {
    'azfw-mapping': spokeName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [for i in range(1, 1): {
      name: 'snet-${i}'
      properties: {
        addressPrefix: '${addressSpacePrefix}.${i - 1}.0/24'
        routeTable: {
          id: spokeRouteTable.id
        }
      }
    }]
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'spoke-to-hub'
  parent: virtualNetwork
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubId
    }
  }
}

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${hubName}/hub-to-${vnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

output id string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
