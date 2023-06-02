###################################
# __        ______  _     ____  
# \ \      / / ___|| |   |___ \ 
#  \ \ /\ / /\___ \| |     __) |
#   \ V  V /  ___) | |___ / __/ 
#    \_/\_/  |____/|_____|_____|
# Run these in WSL2
###################################

# Enable auto export
set -a

# All the variables for the deployment
subscription_name="development"
appgw_name="agw-workload-000010"

resource_group_name="rg-azure-firewall-and-network-testing-workloads"

location="northeurope"

az feature register --name EnableApplicationGatewayNetworkIsolation --namespace Microsoft.Network

##############################################
#   ____                _
#  / ___|_ __ ___  __ _| |_ ___
# | |   | '__/ _ \/ _` | __/ _ \
# | |___| | |  __/ (_| | ||  __/
#  \____|_|  \___|\__,_|\__\___|
# Create workload Private Application Gateway
##############################################

az group create -l $location -n $resource_group_name -o table

#######################
# __   ___ __ ___  
# \ \ / / '_ ` _ \ 
#  \ V /| | | | | |
#   \_/ |_| |_| |_|
# inside management VM 
#######################

aci_ip="http://10.10.2.4"

curl -X POST --data "HTTP GET \"http://10.1.0.4\"" "$aci_ip/api/commands" # Deny

# Exit VM
exit

# Clean up
az group delete --name $resource_group_name -y
