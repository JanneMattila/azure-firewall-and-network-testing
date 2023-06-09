##################################
#     _           _____
#    / \    ____ |  ___|_      __
#   / _ \  |_  / | |_  \ \ /\ / /
#  / ___ \  / /  |  _|  \ V  V /
# /_/   \_\/___| |_|     \_/\_/
# and network testing script
##################################

# Remember to update you Azure Az PowerShell module!
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.0.0
Update-Module Az

# Login to Azure
Login-AzAccount

# *Explicitly* select your working context
Select-AzSubscription -Subscription "<YourSubscriptionName>"

# To understand the demo structure better, see tree of directories
tree

$username = "jumpboxuser"
$plainTextPassword = (New-Guid).ToString() + (New-Guid).ToString().ToUpper()
$plainTextPassword
$plainTextPassword >> .env # Save password to .env file
$password = ConvertTo-SecureString -String $plainTextPassword -AsPlainText
$resourceGroupName = "rg-azure-firewall-and-network-testing"

# Run deployment in single command
$global:result = .\deploy\deploy.ps1 -Username $username -Password $password -ResourceGroupName $resourceGroupName

# Run deployment using multi-line command to print the deployment duration (you need to execute all lines)
Measure-Command -Expression {
    $global:result = .\deploy\deploy.ps1 `
        -Username $username `
        -Password $password `
        -ResourceGroupName $resourceGroupName
} | Format-Table

# Note: If you get deployment errors, then you can see details in either:
# - Resource Group -> Activity log
# - Resource Group -> Deployments

$bastion = $result.Outputs.bastionName.value
$virtualMachineResourceId = $result.Outputs.virtualMachineResourceId.value

$bastion
$virtualMachineResourceId

# Few notes about deployment:
# - Same deployment can be executed in pipeline
#   by Azure AD Service Principal
# - You can deploy this to multiple resources groups
#   - This is extremely handy since deleting also takes time
# - Initial deployment takes roughly 30 minutes
# - Incremental deployments take roughly 15 minutes

###############################
#  ____
# |  _ \  ___ _ __ ___   ___
# | | | |/ _ \ '_ ` _ \ / _ \
# | |_| |  __/ | | | | | (_) |
# |____/ \___|_| |_| |_|\___/
# script
###############################

# 1. Open VM Blade -> Connect -> Bastion
# 2. Use following credentials:
$username
$username | clip
$plainTextPassword
$plainTextPassword | clip

# Connect to a VM using a native client
# https://learn.microsoft.com/en-us/azure/bastion/connect-native-client-windows
az login -o none

az extension add --upgrade --yes --name ssh
az extension add --upgrade --yes --name bastion

az network bastion ssh `
    --name $bastion `
    --resource-group $resourceGroupName `
    --target-resource-id $virtualMachineResourceId `
    --username $username `
    --auth-type password

# Now you can execute commands from our jumbox
spoke1="http://10.1.0.4"
spoke2="http://10.2.0.4"
spoke3="http://10.3.0.4"
curl $spoke1
# -> <html><body>Hello
curl $spoke2
# -> <html><body>Hello
curl $spoke3
# -> <html><body>Hello

# Test outbound internet accesses
BODY=$(echo "HTTP GET \"https://github.com\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://www.microsoft.com\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://www.bing.com\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://docs.microsoft.com\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke3/api/commands" # OK (due to routing)

# Test outbound vnet-to-vnet using http on port 80
# Spoke001 -> Spoke002, Spoke003 - Both OK
curl -X POST --data  "HTTP GET \"$spoke2\"" -H "Content-Type: text/plain" "$spoke1/api/commands" # OK
curl -X POST --data  "HTTP GET \"$spoke3\"" -H "Content-Type: text/plain" "$spoke1/api/commands" # OK

# Spoke002 -> Spoke001 OK but, Spoke003 is denied by firewall
curl -X POST --data  "HTTP GET \"$spoke1\"" -H "Content-Type: text/plain" "$spoke2/api/commands" # OK
curl -X POST --data  "HTTP GET \"$spoke3\"" -H "Content-Type: text/plain" "$spoke2/api/commands" # Deny

# Spoke003 -> Spoke001 is denied by firewall
curl -X POST --data  "HTTP GET \"$spoke1\"" -H "Content-Type: text/plain" "$spoke3/api/commands" # Deny
# Spoke003 -> Spoke002 timeouts, because there is no route and you cannot reach the target server
curl -X POST --data  "HTTP GET \"$spoke2\"" -H "Content-Type: text/plain" "$spoke3/api/commands" # Timeout

# Exit ssh (our jumpbox)
exit

# https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmruncommand?view=azps-7.0.0
# Get-AzVMRunCommand

######################
#  _  _____  _
# | |/ / _ \| |
# | ' / | | | |
# | . \ |_| | |___
# |_|\_\__\_\_____|
# 
######################

$WorkspaceName = "log-firewall"
$workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $resourceGroupName

$query = "AZFWApplicationRule
| where TimeGenerated > ago(1h) and SourceIp startswith '10.10.' and Action == 'Allow'
| summarize count() by Protocol, DestinationPort, Fqdn"

$query = "AZFWApplicationRule
| where TimeGenerated > ago(1h) and SourceIp startswith '10.10.' and Action == 'Deny'
| summarize count() by Protocol, DestinationPort, Fqdn"

$query = "AZFWApplicationRule
| where TimeGenerated > ago(4h) and Action == 'Allow'
| summarize count() by Protocol, DestinationPort, Fqdn"

$query = "AZFWApplicationRule
| where TimeGenerated > ago(1h) and Action == 'Deny'
| summarize count() by Protocol, DestinationPort, Fqdn"

$query
$queryResult = Invoke-AzOperationalInsightsQuery -Workspace $workspace -Query $query
$queryResult.Results | Format-Table

# To get in markdown format
# Install-Module FormatMarkdownTable
$queryResult.Results | Format-MarkdownTableTableStyle Count, DestinationPort, Fqdn, Protocol

##################################################################################
#     _         _______        __ __        __         _    _                 _
#    / \    ___|  ___\ \      / / \ \      / /__  _ __| | _| | ___   __ _  __| |
#   / _ \  |_  / |_   \ \ /\ / /   \ \ /\ / / _ \| '__| |/ / |/ _ \ / _` |/ _` |
#  / ___ \  / /|  _|   \ V  V /     \ V  V / (_) | |  |   <| | (_) | (_| | (_| |
# /_/   \_\/___|_|      \_/\_/       \_/\_/ \___/|_|  |_|\_\_|\___/ \__,_|\__,_|
#  ____                  _  __ _        ____        _
# / ___| _ __   ___  ___(_)/ _(_) ___  |  _ \ _   _| | ___  ___
# \___ \| '_ \ / _ \/ __| | |_| |/ __| | |_) | | | | |/ _ \/ __|
#  ___) | |_) |  __/ (__| |  _| | (__  |  _ <| |_| | |  __/\__ \
# |____/| .__/ \___|\___|_|_| |_|\___| |_| \_\\__,_|_|\___||___/
#       |_| 
##################################################################################

# Private Azure Kubernetes Service (AKS) rule deployment
New-AzResourceGroupDeployment `
    -DeploymentName "AKS-$((Get-Date).ToString("yyyy-MM-dd-HH-mm-ss"))" `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile .\workloads\private-aks\firewall-policy.bicep `
    -Force `
    -Verbose

##################################
#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
# up demo resources 
##################################

Remove-AzResourceGroup -Name $resourceGroupName -Force
