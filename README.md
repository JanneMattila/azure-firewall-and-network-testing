# Azure Firewall and network testing

Azure Firewall and network testing enables you quickly deploy following environment

![Azure Firewall and network testing architecture](https://github.com/JanneMattila/azure-firewall-and-network-testing/assets/2357647/afc9c55e-2cfb-417d-ab1e-9576d4b9aaf0)

You can use this infrastructure to test networking requirements of different
Azure Services and helps you in their firewall rule development.

## Example workload deployments

[Private AKS](./workloads/private-aks)

[Private ACI](./workloads/private-aci)

## Usage

1. Clone this repository to your own machine.
  - If you decide to download this as zip instead, then remember to `Unblock file` before extracting the content. 
    Otherwise you might get `Run only scripts that you trust. While scripts from the internet can be useful,this script can potentially harm your computer. If you trust this script, use the Unblock-File cmdlet to allow the script to run without this warning message` error. See also [Unblock-File](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file) for more details.
2. Update Azure `Az` PowerShell module ([instructions](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.0.0))
3. Install [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-powershell)
4. Open [run.ps1](run.ps1) to walk through steps to deploy this demo environment
  - Execute different script steps one-by-one (hint: use [shift-enter](https://github.com/JanneMattila/some-questions-and-some-answers/blob/master/q%26a/vs_code.md#automation-tip-shift-enter))
