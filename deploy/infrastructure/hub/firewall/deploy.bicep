param name string = 'afw-hub'
param location string
param firewallSubnetId string

module firewallPolicy 'firewall-policy-empty.bicep' = {
  name: 'firewallPolicy-deployment'
  params: {
    location: location
  }
}

module publicIp 'public-ip.bicep' = {
  name: 'firewall-pip-deployment'
  params: {
    name: 'pip-firewall'
    location: location
  }
}

module firewall 'firewall.bicep' = {
  name: 'firewall-deployment'
  params: {
    name: name
    firewallPolicyId: firewallPolicy.outputs.id
    ip: {
      publicIp: publicIp.outputs.id
      subnet: firewallSubnetId
    }
    location: location
  }
}

output firewallPrivateIp string = firewall.outputs.privateIPAddress
