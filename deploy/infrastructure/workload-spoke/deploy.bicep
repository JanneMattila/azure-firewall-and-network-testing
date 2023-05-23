param spokeName string
param addressSpacePrefix string
param hubName string
param hubId string
param firewallIpAddress string
param username string
@secure()
param password string
param location string = resourceGroup().location

var vnetName = 'vnet-${spokeName}'
var bastionName = 'bas-management'

var vnetAddressSpace = '${addressSpacePrefix}.0.0/16'

resource spokeRouteTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'rt-${spokeName}-1'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'All'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${spokeName}-1'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allowAllRule'
        properties: {
          description: 'Allow all traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
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
    subnets: [
      {
        // For our demo management subnet to host our VMs
        name: 'snet-management'
        properties: {
          addressPrefix: '${addressSpacePrefix}.0.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${addressSpacePrefix}.1.0/24'
        }
      }
      {
        name: 'snet-1'
        properties: {
          addressPrefix: '${addressSpacePrefix}.2.0/24'
          routeTable: {
            id: spokeRouteTable.id
          }
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: 'snet-2'
        properties: {
          addressPrefix: '${addressSpacePrefix}.3.0/24'
          routeTable: {
            id: spokeRouteTable.id
          }
        }
      }
      {
        name: 'snet-3'
        properties: {
          addressPrefix: '${addressSpacePrefix}.4.0/24'
          routeTable: {
            id: spokeRouteTable.id
          }
        }
      }
    ]
  }
}

var managementSubnetId = virtualNetwork.properties.subnets[0].id
var bastionSubnetId = virtualNetwork.properties.subnets[1].id

module bastion 'bastion.bicep' = {
  name: 'bastion-deployment'
  params: {
    name: bastionName
    location: location
    subnetId: bastionSubnetId
  }
}

module jumpbox 'jumpbox.bicep' = {
  name: 'jumpbox-deployment'
  params: {
    name: 'jumpbox'
    username: username
    password: password
    location: location
    subnetId: managementSubnetId
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'spoke-to-hub'
  parent: virtualNetwork
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false // No VPN gateway in this example
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

output bastionName string = bastionName
output virtualMachineResourceId string = jumpbox.outputs.virtualMachineResourceId
