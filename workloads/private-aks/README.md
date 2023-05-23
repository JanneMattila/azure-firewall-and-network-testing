# Private AKS

[Azure Global required FQDN / application rules](https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-fqdn--application-rules)

## No connectivity

User Defined Route (UDR) implemented in AKS subnet to route all traffic to Azure Firewall in a hub VNET.

```bash
ERROR: (CreateVMSSAgentPoolFailed) Unable to establish outbound connection from agents, please see https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror and https://aka.ms/aks-required-ports-and-addresses for more information. Details: Code="VMExtensionProvisioningError" Message="VM has reported a failure when processing extension 'vmssCSE'. Error message: \"Enable failed: failed to execute command: command terminated with exit status=50\n[stdout]\n{ \"ExitCode\": \"50\", \"Output\": \"sh for Ubuntu'\\nSourcing cse_helpers_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs.sh\\n+ echo /opt/azure/containers/provision_installs.sh\\n+ source /opt/azure/containers/provision_installs.sh\\n++ CC_SERVICE_IN_TMP=/opt/azure/containers/cc-proxy.service.in\\n++ CC_SOCKET_IN_TMP=/opt/azure/containers/cc-proxy.socket.in\\n++ CNI_CONFIG_DIR=/etc/cni/net.d\\n++ CNI_BIN_DIR=/opt/cni/bin\\n++ CNI_DOWNLOADS_DIR=/opt/cni/downloads\\n++ CRICTL_DOWNLOAD_DIR=/opt/crictl/downloads\\n++ CRICTL_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_DOWNLOADS_DIR=/opt/containerd/downloads\\n++ RUNC_DOWNLOADS_DIR=/opt/runc/downloads\\n++ K8S_DOWNLOADS_DIR=/opt/kubernetes/downloads\\n+++ lsb_release -r -s\\n++ UBUNTU_RELEASE=22.04\\n++ TELEPORTD_PLUGIN_DOWNLOAD_DIR=/opt/teleportd/downloads\\n++ TELEPORTD_PLUGIN_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_WASM_VERSIONS='v0.3.0 v0.5.1'\\n++ MANIFEST_FILEPATH=/opt/azure/manifest.json\\n++ MAN_DB_AUTO_UPDATE_FLAG_FILEPATH=/var/lib/man-db/auto-update\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs_distro.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs_distro.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs_distro.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs_distro.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs_distro.sh\\n+ echo /opt/azure/containers/provision_installs_distro.sh\\n+ source /opt/azure/containers/provision_installs_distro.sh\\n++ echo 'Sourcing cse_install_distro.sh for Ubuntu'\\nSourcing cse_install_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_configs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_configs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_configs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_configs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_configs.sh\\n+ echo /opt/azure/containers/provision_configs.sh\\n+ source /opt/azure/containers/provision_configs.sh\\n+++ hostname\\n+++ tail -c 2\\n++ NODE_INDEX=0\\n+++ hostname\\n++ NODE_NAME=aks-nodepool1-21342552-vmss000000\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ -n curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/ ]]\\n+ [[ -n '' ]]\\n+ retrycmd_if_failure 50 1 5 curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/\\n+ exit 50\", \"Error\": \"\", \"ExecDuration\": \"50\", \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CloudInitLocalStartTime\": \"Tue 2023-05-23 08:34:12 UTC\", \"CloudInitStartTime\": \"Tue 2023-05-23 08:34:15 UTC\", \"CloudFinalStartTime\": \"Tue 2023-05-23 08:34:22 UTC\", \"NetworkdStartTime\": \"Tue 2023-05-23 08:34:13 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"SystemdSummary\": \"Startup finished in 546ms (firmware) + 1.203s (loader) + 1.270s (kernel) + 11.207s (userspace) = 14.227s \\ngraphical.target reached after 10.457s in userspace\", \"BootDatapoints\": { \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"KubeletStartTime\": \"n/a\" } }\n\n[stderr]\ndate: invalid date ‘n/a’\n\"\r\n\r\nMore information on troubleshooting is available at https://aka.ms/VMExtensionCSELinuxTroubleshoot " Target="0"
Code: CreateVMSSAgentPoolFailed
Message: Unable to establish outbound connection from agents, please see https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror and https://aka.ms/aks-required-ports-and-addresses for more information. Details: Code="VMExtensionProvisioningError" Message="VM has reported a failure when processing extension 'vmssCSE'. Error message: \"Enable failed: failed to execute command: command terminated with exit status=50\n[stdout]\n{ \"ExitCode\": \"50\", \"Output\": \"sh for Ubuntu'\\nSourcing cse_helpers_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs.sh\\n+ echo /opt/azure/containers/provision_installs.sh\\n+ source /opt/azure/containers/provision_installs.sh\\n++ CC_SERVICE_IN_TMP=/opt/azure/containers/cc-proxy.service.in\\n++ CC_SOCKET_IN_TMP=/opt/azure/containers/cc-proxy.socket.in\\n++ CNI_CONFIG_DIR=/etc/cni/net.d\\n++ CNI_BIN_DIR=/opt/cni/bin\\n++ CNI_DOWNLOADS_DIR=/opt/cni/downloads\\n++ CRICTL_DOWNLOAD_DIR=/opt/crictl/downloads\\n++ CRICTL_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_DOWNLOADS_DIR=/opt/containerd/downloads\\n++ RUNC_DOWNLOADS_DIR=/opt/runc/downloads\\n++ K8S_DOWNLOADS_DIR=/opt/kubernetes/downloads\\n+++ lsb_release -r -s\\n++ UBUNTU_RELEASE=22.04\\n++ TELEPORTD_PLUGIN_DOWNLOAD_DIR=/opt/teleportd/downloads\\n++ TELEPORTD_PLUGIN_BIN_DIR=/usr/local/bin\\n++ CONTAINERD_WASM_VERSIONS='v0.3.0 v0.5.1'\\n++ MANIFEST_FILEPATH=/opt/azure/manifest.json\\n++ MAN_DB_AUTO_UPDATE_FLAG_FILEPATH=/var/lib/man-db/auto-update\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_installs_distro.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_installs_distro.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_installs_distro.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_installs_distro.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_installs_distro.sh\\n+ echo /opt/azure/containers/provision_installs_distro.sh\\n+ source /opt/azure/containers/provision_installs_distro.sh\\n++ echo 'Sourcing cse_install_distro.sh for Ubuntu'\\nSourcing cse_install_distro.sh for Ubuntu\\n+ wait_for_file 3600 1 /opt/azure/containers/provision_configs.sh\\n+ retries=3600\\n+ wait_sleep=1\\n+ filepath=/opt/azure/containers/provision_configs.sh\\n+ paved=/opt/azure/cloud-init-files.paved\\n+ grep -Fq /opt/azure/containers/provision_configs.sh /opt/azure/cloud-init-files.paved\\n++ seq 1 3600\\n+ for i in $(seq 1 $retries)\\n+ grep -Fq '#EOF' /opt/azure/containers/provision_configs.sh\\n+ break\\n+ sed -i /#EOF/d /opt/azure/containers/provision_configs.sh\\n+ echo /opt/azure/containers/provision_configs.sh\\n+ source /opt/azure/containers/provision_configs.sh\\n+++ hostname\\n+++ tail -c 2\\n++ NODE_INDEX=0\\n+++ hostname\\n++ NODE_NAME=aks-nodepool1-21342552-vmss000000\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ false == \\\\t\\\\r\\\\u\\\\e ]]\\n+ [[ -n curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/ ]]\\n+ [[ -n '' ]]\\n+ retrycmd_if_failure 50 1 5 curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/\\n+ exit 50\", \"Error\": \"\", \"ExecDuration\": \"50\", \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CloudInitLocalStartTime\": \"Tue 2023-05-23 08:34:12 UTC\", \"CloudInitStartTime\": \"Tue 2023-05-23 08:34:15 UTC\", \"CloudFinalStartTime\": \"Tue 2023-05-23 08:34:22 UTC\", \"NetworkdStartTime\": \"Tue 2023-05-23 08:34:13 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"SystemdSummary\": \"Startup finished in 546ms (firmware) + 1.203s (loader) + 1.270s (kernel) + 11.207s (userspace) = 14.227s \\ngraphical.target reached after 10.457s in userspace\", \"BootDatapoints\": { \"KernelStartTime\": \"Tue 2023-05-23 08:34:10 UTC\", \"CSEStartTime\": \"Tue May 23 08:35:29 UTC 2023\", \"GuestAgentStartTime\": \"Tue 2023-05-23 08:34:21 UTC\", \"KubeletStartTime\": \"n/a\" } }\n\n[stderr]\ndate: invalid date ‘n/a’\n\"\r\n\r\nMore information on troubleshooting is available at https://aka.ms/VMExtensionCSELinuxTroubleshoot " Target="0"
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