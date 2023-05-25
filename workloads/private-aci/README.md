# Private ACI

# No connectivity

```
ERROR: (InaccessibleImage) The image 'crazfwdemo000010.azurecr.io/apps/webapp-network-tester:1.0.56' in container group 'ci-workload' is not accessible. Please check the image and registry credential.
Code: InaccessibleImage
Message: The image 'crazfwdemo000010.azurecr.io/apps/webapp-network-tester:1.0.56' in container group 'ci-workload' is not accessible. Please check the image and registry credential.
```

```bicep
{
  ruleType: 'ApplicationRule'
  name: 'Allow container images from private Azure Container Registry'
  description: 'For more details see: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link'
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
    'crazfwdemo000010.azurecr.io'
    'crazfwdemo000010.northeurope.data.azurecr.io'
  ]
}
```

## Links

[Allow trusted services to securely access a network-restricted container registry](https://learn.microsoft.com/en-us/azure/container-registry/allow-access-trusted-services)
