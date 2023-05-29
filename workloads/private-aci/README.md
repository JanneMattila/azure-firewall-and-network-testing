# Private ACI

# InaccessibleImage

If you try to deploy ACI and get following error:

```
ERROR: (InaccessibleImage) The image 'crazfwdemo000010.azurecr.io/apps/jannemattila/webapp-network-tester:1.0.56' in container group 'ci-workload' is not accessible. Please check the image and registry credential.
Code: InaccessibleImage
Message: The image 'crazfwdemo000010.azurecr.io/apps/jannemattila/webapp-network-tester:1.0.56' in container group 'ci-workload' is not accessible. Please check the image and registry credential.
```

It means that `Allow trusted Microsoft services to access this container registry` is not enabled for that container registry.

[Allow trusted services to securely access a network-restricted container registry](https://learn.microsoft.com/en-us/azure/container-registry/allow-access-trusted-services)

From [Trusted Services](https://learn.microsoft.com/en-us/azure/container-registry/allow-access-trusted-services#trusted-services):

> Instances of the following services can access a network-restricted container registry
> if the registry's allow trusted services setting is enabled (the default)
