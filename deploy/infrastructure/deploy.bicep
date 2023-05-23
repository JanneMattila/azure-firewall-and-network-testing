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

module workloadSpokeDeployments 'workload-spoke/deploy.bicep' = {
  name: 'workload-spoke-deployment'
  params: {
    spokeName: 'spoke-workload'
    hubName: hubVNetName
    hubId: hub.outputs.id
    location: location
    firewallIpAddress: firewallIpAddress
    addressSpacePrefix: '10.10'
    username: username
    password: password
  }
  dependsOn: [
    hub
  ]
}

module workloadOtherSpokeDeployments 'other-workload-spoke/deploy.bicep' = {
  name: 'other-workload-spoke-deployment'
  params: {
    spokeName: 'spoke-other-workload'
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

output bastionName string = workloadSpokeDeployments.outputs.bastionName
output virtualMachineResourceId string = workloadSpokeDeployments.outputs.virtualMachineResourceId
output firewallPrivateIp string = hub.outputs.firewallPrivateIp
