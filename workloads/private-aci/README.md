# Private ACI

# Inaccessible Image from Private ACR

If you try to deploy ACI and get following error when pulling the image from private ACR:

```
ERROR: (InaccessibleImage) The image 'crazfwdemo000010.azurecr.io/apps/jannemattila/webapp-network-tester:1.0.56' in container group 'ci-workload' is not accessible. Please check the image and registry credential.
Code: InaccessibleImage
Message: The image 'crazfwdemo000010.azurecr.io/apps/jannemattila/webapp-network-tester:1.0.56' in container group 'ci-workload' is not accessible. Please check the image and registry credential.
```

It means that `Allow trusted Microsoft services to access this container registry` is not enabled for that container registry ([link](https://learn.microsoft.com/en-us/azure/container-instances/using-azure-container-registry-mi#configure-registry-authentication)).

[Allow trusted services to securely access a network-restricted container registry](https://learn.microsoft.com/en-us/azure/container-registry/allow-access-trusted-services)

> Several multi-tenant Azure services operate from networks that can't be included in these registry network settings,
> preventing them from performing operations such as pull or push images to the registry. 
> By designating certain service instances as "trusted", a registry owner can allow select 
> Azure resources to securely bypass the registry's network settings to perform registry operations.

From [Trusted Services](https://learn.microsoft.com/en-us/azure/container-registry/allow-access-trusted-services#trusted-services):

> Instances of the following services can access a network-restricted container registry
> if the registry's allow trusted services setting is enabled (the default)

After image is successfully pulled and ACI is running, then User Defined Routes (UDR)
and Network Security Groups (NSG) can be used for controlling the traffic from the ACI.
