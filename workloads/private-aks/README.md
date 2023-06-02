# Private AKS

> **Warning**
> If you plan to deploy AKS into environment which has route `0.0.0.0/0` to your
> firewall, then you *must* make the required firewall openings before deploying AKS.
> **Otherwise AKS deployment will fail**.
> 
> Follow these instruction for the required openings:
> [Outbound rules](https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress)

This below document tries to explain various problems that you might see 
if you don't have the required connectivity from the AKS cluster to the required targets.

If you see *any of the below problems*, then you need to double check that
you have the required connectivity from the AKS cluster to the required targets as documented in the above link.

You can test the connectivity requirements from virtual machine in same virtual network:

```bash
curl -L https://raw.githubusercontent.com/JanneMattila/network-test-scripts/main/aks.sh | bash -s -- westeurope
```

Script can be found from [JanneMattila/network-test-scripts](https://github.com/JanneMattila/network-test-scripts).

## No connectivity

User Defined Route (UDR) implemented in AKS subnet to route all traffic to Azure Firewall in a hub VNET.

Here is example error message if required connectivity is not enabled:

```bash
ERROR: (CreateVMSSAgentPoolFailed) Unable to establish outbound connection from agents, 
please see https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror
and https://aka.ms/aks-required-ports-and-addresses for more information. 
Details: Code="VMExtensionProvisioningError" Message="VM has reported a failure when processing extension 'vmssCSE'. 
Error message: \"Enable failed: failed to execute command: command terminated with exit status=50\n[stdout]\n
{ \"ExitCode\": \"50\", \"Output\": \"sh for Ubuntu'\\nSourcing cse_helpers_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 
/opt/azure/containers/provision_installs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs.sh\\n+ echo /opt/azure/containers/provision_installs.sh\\n+ source /opt/azure/containers/provision_installs.sh\\n++ CC_SERVICE_IN_TMP=/opt/azure/containers/cc-proxy.service.in\\n++ CC_SOCKET_IN_TMP=/opt/azure/containers/cc-proxy.socket.in\\n++ CNI_CONFIG_DIR=/etc/cni/net.d\\n++ CNI_BIN_DIR=/opt/cni/bin\\n++ CNI_DOWNLOADS_DIR=/opt/cni/downloads\\n++ CRICTL_DOWNLOAD_DIR=/opt/crictl/downloads\\n++ CRICTL_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_DOWNLOADS_DIR=/opt/containerd/downloads\\n++ RUNC_DOWNLOADS_DIR=/opt/runc/downloads\\n++ K8S_DOWNLOADS_DIR=/opt/kubernetes/downloads\\n+++ lsb_release -r -s\\n++ UBUNTU_RELEASE=22.04\\n++ TELEPORTD_PLUGIN_DOWNLOAD_DIR=/opt/teleportd/downloads\\n++ TELEPORTD_PLUGIN_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_WASM_VERSIONS='v0.3.0 v0.5.1'\\n++ MANIFEST_FILEPATH=/opt/azure/manifest.json\\n++ MAN_DB_AUTO_UPDATE_FLAG_FILEPATH=/var/lib/man-db/auto-update\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs_distro.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs_distro.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs_distro.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs_distro.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs_distro.sh\\n+ echo /opt/azure/containers/provision_installs_distro.sh\\n+ source /opt/azure/containers/provision_installs_distro.sh\\n++ echo 'Sourcing cse_install_distro.sh for Ubuntu'\\nSourcing cse_install_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_configs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_configs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_configs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_configs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_configs.sh\\n+ echo /opt/azure/containers/provision_configs.sh\\n+ source /opt/azure/containers/provision_configs.sh\\n+++ hostname\\n+++ tail -c 2\\n++ NODE_INDEX=0\\n+++ hostname\\n++ NODE_NAME=aks-nodepool1-21342552-vmss000000\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ -n curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/ ]]\\n+ [[ -n '' ]]\\n+ retrycmd_if_failure 50 1 5 curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/\\n+ exit 50\", \"Error\": \"\", \"ExecDuration\": \"50\", \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CloudInitLocalStartTime\": \"Tue 2023-05-23 08:34:12 UTC\", \"CloudInitStartTime\": \"Tue 2023-05-23 08:34:15 UTC\", \"CloudFinalStartTime\": \"Tue 2023-05-23 08:34:22 UTC\", \"NetworkdStartTime\": \"Tue 2023-05-23 08:34:13 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"SystemdSummary\": \"Startup finished in 546ms (firmware) + 1.203s (loader) + 1.270s (kernel) + 11.207s (userspace) = 14.227s \\ngraphical.target reached after 10.457s in userspace\", \"BootDatapoints\": { \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"KubeletStartTime\": \"n/a\" } }\n\n[stderr]\ndate: invalid date ‘n/a’\n\"\r\n\r\nMore information on troubleshooting is available at https://aka.ms/VMExtensionCSELinuxTroubleshoot " Target="0"
Code: CreateVMSSAgentPoolFailed
Message: Unable to establish outbound connection from agents, please see https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror
and https://aka.ms/aks-required-ports-and-addresses for more information. 
Details: Code="VMExtensionProvisioningError" Message="VM has reported a failure when processing extension 'vmssCSE'. 
Error message: \"Enable failed: failed to execute command: command terminated with exit status=50
\n[stdout]\n{ \"ExitCode\": \"50\", \"Output\": \"sh for Ubuntu'\\nSourcing cse_helpers_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs.sh\\n+ echo /opt/azure/containers/provision_installs.sh\\n+ source /opt/azure/containers/provision_installs.sh\\n++ CC_SERVICE_IN_TMP=/opt/azure/containers/cc-proxy.service.in\\n++ CC_SOCKET_IN_TMP=/opt/azure/containers/cc-proxy.socket.in\\n++ CNI_CONFIG_DIR=/etc/cni/net.d\\n++ CNI_BIN_DIR=/opt/cni/bin\\n++ CNI_DOWNLOADS_DIR=/opt/cni/downloads\\n++ CRICTL_DOWNLOAD_DIR=/opt/crictl/downloads\\n++ CRICTL_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_DOWNLOADS_DIR=/opt/containerd/downloads\\n++ RUNC_DOWNLOADS_DIR=/opt/runc/downloads\\n++ K8S_DOWNLOADS_DIR=/opt/kubernetes/downloads\\n+++ lsb_release -r -s\\n++ UBUNTU_RELEASE=22.04\\n++ TELEPORTD_PLUGIN_DOWNLOAD_DIR=/opt/teleportd/downloads\\n++ TELEPORTD_PLUGIN_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_WASM_VERSIONS='v0.3.0 v0.5.1'\\n++ MANIFEST_FILEPATH=/opt/azure/manifest.json\\n++ MAN_DB_AUTO_UPDATE_FLAG_FILEPATH=/var/lib/man-db/auto-update\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs_distro.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs_distro.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs_distro.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs_distro.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs_distro.sh\\n+ echo /opt/azure/containers/provision_installs_distro.sh\\n+ source /opt/azure/containers/provision_installs_distro.sh\\n++ echo 'Sourcing cse_install_distro.sh for Ubuntu'\\nSourcing cse_install_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_configs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_configs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_configs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_configs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_configs.sh\\n+ echo /opt/azure/containers/provision_configs.sh\\n+ source /opt/azure/containers/provision_configs.sh\\n+++ hostname\\n+++ tail -c 2\\n++ NODE_INDEX=0\\n+++ hostname\\n++ NODE_NAME=aks-nodepool1-21342552-vmss000000\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ -n curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/ ]]\\n+ [[ -n '' ]]\\n+ retrycmd_if_failure 50 1 5 curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/\\n+ exit 50\", \"Error\": \"\", \"ExecDuration\": \"50\", \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CloudInitLocalStartTime\": \"Tue 2023-05-23 08:34:12 UTC\", \"CloudInitStartTime\": \"Tue 2023-05-23 08:34:15 UTC\", \"CloudFinalStartTime\": \"Tue 2023-05-23 08:34:22 UTC\", \"NetworkdStartTime\": \"Tue 2023-05-23 08:34:13 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"SystemdSummary\": \"Startup finished in 546ms (firmware) + 1.203s (loader) + 1.270s (kernel) + 11.207s (userspace) = 14.227s \\ngraphical.target reached after 10.457s in userspace\", \"BootDatapoints\": { \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"KubeletStartTime\": \"n/a\" } }\n\n[stderr]\ndate: invalid date ‘n/a’\n\"\r\n\r\n
More information on troubleshooting is available at https://aka.ms/VMExtensionCSELinuxTroubleshoot " Target="0"
```

Important highlights from the above:

> Unable to establish outbound connection from agents, please see [https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror) 
> and [https://aka.ms/aks-required-ports-and-addresses](https://aka.ms/aks-required-ports-and-addresses) for more information

In Azure Portal you can see the following:

> This cluster is in a failed state. 
> If you didn't do an operation, AKS may resolve the provisioning status automatically if your cluster applications continue to run. 
> [Learn more](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/cluster-provisioning-status-changed-ready-failed)

You can query Azure Firewall to see more details about the blocked traffic:

```kql
AZFWApplicationRule
| where SourceIp startswith "10.10."
| summarize count() by Protocol, DestinationPort, Fqdn
```

| Protocol | DestinationPort | Fqdn                                                          | count_ |
| -------- | --------------- | ------------------------------------------------------------- | ------ |
| HTTPS    | 443             | 38c1758a-197e-44fc-83f8-31bb7619a8bc.ods.opinsights.azure.com | 273    |
| HTTPS    | 443             | dc.services.visualstudio.com                                  | 47     |
| HTTPS    | 443             | mcr.microsoft.com                                             | 50     |
| HTTPS    | 443             | md-hdd-b4rzwnpfspxt.z38.blob.storage.azure.net                | 12     |
| HTTPS    | 443             | umsah0wq3xfzjmklf2nk.blob.core.windows.net                    | 6      |

You can use PowerShell to query the Azure Log Analytics workspace:

```powershell
$WorkspaceName = "log-firewall"
$ResourceGroupName = "rg-azure-firewall-and-network-testing"

$query = "AZFWApplicationRule
| where SourceIp startswith "10.10."
| summarize count() by Protocol, DestinationPort, Fqdn"
$query
$workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName

$queryResult = Invoke-AzOperationalInsightsQuery -Workspace $workspace -Query $query
$queryResult.Results | Format-Table
```

![KQL query output](https://github.com/JanneMattila/azure-firewall-and-network-testing/assets/2357647/096ee002-b3f8-4e16-9dd7-cdf86a0713c2)

## "mcr.microsoft.com" allowed

The following is the Application Rule that is required to access images in Microsoft Container Registry (MCR).

`mcr.microsoft.com`:

> Required to access images in Microsoft Container Registry (MCR). This registry contains first-party images/charts (for example, coreDNS, etc.). 
> These images are required for the correct creation and functioning of the cluster, including scale and upgrade operations.

`*.data.mcr.microsoft.com`:

> Required for MCR storage backed by the Azure content delivery network (CDN).

```bicep
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
```

```kql
AZFWApplicationRule
| where SourceIp startswith '10.10.' and Action == 'Deny'
| summarize count() by Protocol, DestinationPort, Fqdn
| order by count_
```

| Protocol | DestinationPort | Fqdn                                                          | count_ |
| -------- | --------------- | ------------------------------------------------------------- | ------ |
| HTTPS    | 443             | 38c1758a-197e-44fc-83f8-31bb7619a8bc.ods.opinsights.azure.com | 423    |
| HTTPS    | 443             | dc.services.visualstudio.com                                  | 158    |
| HTTPS    | 443             | northeurope.monitoring.azure.com                              | 44     |
| HTTPS    | 443             | md-hdd-b4rzwnpfspxt.z38.blob.storage.azure.net                | 12     |
| HTTPS    | 443             | 38c1758a-197e-44fc-83f8-31bb7619a8bc.oms.opinsights.azure.com | 11     |
| HTTPS    | 443             | esm.ubuntu.com                                                | 8      |
| HTTPS    | 443             | packages.microsoft.com                                        | 8      |
| HTTPS    | 443             | umsanpnjwjtt1kbrqrqj.blob.core.windows.net                    | 6      |
| HTTPS    | 443             | data.policy.core.windows.net                                  | 4      |
| HTTP/1.1 | 80              | azure.archive.ubuntu.com                                      | 4      |
| HTTPS    | 443             | motd.ubuntu.com                                               | 4      |

## Monitoring and logging endpoints allowed

The following is the Application Rule that is required to access monitoring and logging endpoints.

```bicep
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
```

## Azure AD endpoint allowed

Here is example error message if required connectivity is not configured:

```
ERROR: No matches in graph database for '2462d71f-4662-4db3-aabd-4290431551ed'
Waiting for AAD role to propagate[###                                 ]  10.0000%
ERROR: No matches in graph database for '2462d71f-4662-4db3-aabd-4290431551ed'
```

The following is the Application Rule that is required to allow Azure Active Directory authentication.

```bicep
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
```

## After the changes

| Protocol | DestinationPort | Fqdn                                           | count_ |
| -------- | --------------- | ---------------------------------------------- | ------ |
| HTTPS    | 443             | motd.ubuntu.com                                | 1      |
| HTTPS    | 443             | esm.ubuntu.com                                 | 2      |
| HTTPS    | 443             | md-hdd-b4rzwnpfspxt.z38.blob.storage.azure.net | 2      |

## After pulling image from Docker Hub

| Protocol | DestinationPort | Fqdn                 | count_ |
| -------- | --------------- | -------------------- | ------ |
| HTTPS    | 443             | registry-1.docker.io | 1      |

```text
app-fs-tester:1.1.13": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/66/667d055e2e09c1a11c7e0e781724a725a8517c6d8df497cbd92eeabf6773610c/data?verify=1685620861-NOkkB9Md%2FTxBMx4WPNnEe15Ikj8%3D": EOF
  Normal   BackOff    23s                kubelet            Back-off pulling image "jannemattila/webapp-fs-tester:1.1.13"
  Warning  Failed     23s                kubelet            Error: ImagePullBackOff
  Normal   Pulling    10s (x2 over 25s)  kubelet            Pulling image "jannemattila/webapp-fs-tester:1.1.13"
  Warning  Failed     8s (x2 over 23s)   kubelet            Error: ErrImagePull
  Warning  Failed     8s                 kubelet            Failed to pull image "jannemattila/webapp-fs-tester:1.1.13": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/jannemattila/webapp-fs-tester:1.1.13": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/66/667d055e2e09c1a11c7e0e781724a725a8517c6d8df497cbd92eeabf6773610c/data?verify=1685620876-SiUjFysV6BA5NJRDy8eulMNiaUA%3D": EOF
```

| Protocol | DestinationPort | Fqdn                             | count_ |
| -------- | --------------- | -------------------------------- | ------ |
| HTTPS    | 443             | production.cloudflare.docker.com | 7      |

## Misc

Azure Disk and example `pv` and `pvc` and `sc`:

```bash
jumpboxuser@jumpbox:~/aks-workshop$ kubectl describe pvc premiumdisk2-storage-app-deployment-0 -n storage-app
Name:          premiumdisk2-storage-app-deployment-0
Namespace:     storage-app
StorageClass:  managed-csi-premium-sc
Status:        Bound
Volume:        pvc-136375d5-5816-45ce-a77b-4755ce386eae
Labels:        app=storage-app
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: disk.csi.azure.com
               volume.kubernetes.io/selected-node: aks-nodepool1-17475938-vmss000000
               volume.kubernetes.io/storage-provisioner: disk.csi.azure.com
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      5Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       storage-app-deployment-0
Events:
  Type    Reason                 Age                 From                                                                                               Message        
  ----    ------                 ----                ----                                                                                               -------        
  Normal  WaitForFirstConsumer   22m (x12 over 25m)  persistentvolume-controller                                                                        waiting for first consumer to be created before binding
  Normal  ExternalProvisioning   22m                 persistentvolume-controller                                                                        waiting for a volume to be created, either by external provisioner "disk.csi.azure.com" or manually created by system administrator
  Normal  Provisioning           22m                 disk.csi.azure.com_csi-azuredisk-controller-67fc899bdc-p8lw9_971d59f6-f403-442f-9adc-92691a50548a  External provisioner is provisioning volume for claim "storage-app/premiumdisk2-storage-app-deployment-0"
  Normal  ProvisioningSucceeded  22m                 disk.csi.azure.com_csi-azuredisk-controller-67fc899bdc-p8lw9_971d59f6-f403-442f-9adc-92691a50548a  Successfully provisioned volume pvc-136375d5-5816-45ce-a77b-4755ce386eae
jumpboxuser@jumpbox:~/aks-workshop$ kubectl describe pv pvc-136375d5-5816-45ce-a77b-4755ce386eae -n storage-app
Name:              pvc-136375d5-5816-45ce-a77b-4755ce386eae
Labels:            <none>
Annotations:       pv.kubernetes.io/provisioned-by: disk.csi.azure.com
                   volume.kubernetes.io/provisioner-deletion-secret-name:
                   volume.kubernetes.io/provisioner-deletion-secret-namespace:
Finalizers:        [kubernetes.io/pv-protection external-attacher/disk-csi-azure-com]
StorageClass:      managed-csi-premium-sc
Status:            Bound
Claim:             storage-app/premiumdisk2-storage-app-deployment-0
Reclaim Policy:    Delete
Access Modes:      RWO
VolumeMode:        Filesystem
Capacity:          5Gi
Node Affinity:
  Required Terms:
    Term 0:        topology.disk.csi.azure.com/zone in []
Message:
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            disk.csi.azure.com
    FSType:
    VolumeHandle:      /subscriptions/59a94869-414f-4a04-9aca-2370777500ef/resourceGroups/mc_rg-azure-firewall-and-network-testing-workloads_aks-workload_northeurope/providers/Microsoft.Compute/disks/pvc-136375d5-5816-45ce-a77b-4755ce386eae
    ReadOnly:          false
    VolumeAttributes:      csi.storage.k8s.io/pv/name=pvc-136375d5-5816-45ce-a77b-4755ce386eae
                           csi.storage.k8s.io/pvc/name=premiumdisk2-storage-app-deployment-0
                           csi.storage.k8s.io/pvc/namespace=storage-app
                           requestedsizegib=5
                           skuName=Premium_LRS
                           storage.kubernetes.io/csiProvisionerIdentity=1685594781122-4892-disk.csi.azure.com
Events:                <none>
jumpboxuser@jumpbox:~/aks-workshop$ kubectl describe sc managed-csi-premium-sc
Name:            managed-csi-premium-sc
IsDefaultClass:  No
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"allowVolumeExpansion":true,"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"managed-csi-premium-sc"},"parameters":{"skuName":"Premium_LRS"},"provisioner":"disk.csi.azure.com","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}

Provisioner:           disk.csi.azure.com
Parameters:            skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
jumpboxuser@jumpbox:~/aks-workshop$
```