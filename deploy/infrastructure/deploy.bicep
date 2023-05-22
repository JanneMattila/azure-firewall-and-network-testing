param location string
param username string
@secure()
param password string

var hubName = 'hub'
var hubVNetName = 'vnet-${hubName}'
var firewallIpAddress = '10.0.1.4'
var all = '0.0.0.0/0'

var spokes = [
  {
    name: 'spoke001'
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24'
  }
]

// All route tables are defined here
resource hubGatewaySubnetRouteTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'rt-${hubName}-gateway'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: spokes[0].name
        properties: {
          addressPrefix: spokes[0].vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}

resource spoke1RouteTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'rt-${spokes[0].name}-front'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'All'
        properties: {
          addressPrefix: all
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}

var spokeRouteTables = [
  {
    id: spoke1RouteTable.id
  }
]

module hub 'hub/deploy.bicep' = {
  name: 'hub-deployment'
  params: {
    name: hubVNetName
    username: username
    password: password
    gatewaySubnetRouteTableId: hubGatewaySubnetRouteTable.id
    location: location
  }
}

module spokeDeployments 'other-spokes/deploy.bicep' = [for (spoke, i) in spokes: {
  name: '${spoke.name}-deployment'
  params: {
    spokeName: spoke.name
    hubName: hubVNetName
    hubId: hub.outputs.id
    location: location
    vnetAddressSpace: spoke.vnetAddressSpace
    subnetAddressSpace: spoke.subnetAddressSpace
    routeTableId: spokeRouteTables[i].id
  }
  dependsOn: [
    hub
  ]
}]

module workloadClientSpokeDeployments 'workload-spoke/deploy.bicep' = {
  name: 'workload--client-spoke-deployment'
  params: {
    spokeName: 'spoke-workload-client'
    hubName: hubVNetName
    hubId: hub.outputs.id
    location: location
    firewallIpAddress: firewallIpAddress
    addressSpacePrefix: '10.10'
  }
  dependsOn: [
    hub
  ]
}

module workloadServerSpokeDeployments 'workload-spoke/deploy.bicep' = {
  name: 'workload--server-spoke-deployment'
  params: {
    spokeName: 'spoke-workload-server'
    hubName: hubVNetName
    hubId: hub.outputs.id
    location: location
    firewallIpAddress: firewallIpAddress
    addressSpacePrefix: '10.11'
  }
  dependsOn: [
    hub
  ]
}

output firewallSubnetId string = hub.outputs.firewallSubnetId
output bastionName string = hub.outputs.bastionName
output virtualMachineResourceId string = hub.outputs.virtualMachineResourceId
