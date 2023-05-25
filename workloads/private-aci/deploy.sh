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
acr_name="crazfwdemo000010"
aci_identity_name="id-aci-workload"
aci_name="ci-workload"

resource_group_name="rg-azure-firewall-and-network-testing-workloads"

network_resource_group_name="rg-azure-firewall-and-network-testing"

location="northeurope"

#################################
#   ____                _
#  / ___|_ __ ___  __ _| |_ ___
# | |   | '__/ _ \/ _` | __/ _ \
# | |___| | |  __/ (_| | ||  __/
#  \____|_|  \___|\__,_|\__\___|
# Create workload Private ACI
#################################

az group create -l $location -n $resource_group_name -o table

acr_json=$(az acr create -l $location -g $resource_group_name -n $acr_name --sku Premium -o json)
echo $acr_json
acr_loginServer=$(echo $acr_json | jq -r .loginServer)
acr_id=$(echo $acr_json | jq -r .id)
echo $acr_loginServer
echo $acr_id

az acr update --name $acr_name --data-endpoint-enabled

image="webapp-network-tester:1.0.56"
az acr import -n $acr_name -t "apps/jannemattila/$image" --source "docker.io/jannemattila/$image" 

aci_subnet_id=$(az network vnet subnet update -g $network_resource_group_name --vnet-name vnet-spoke-workload \
  --name snet-1 --delegations "Microsoft.ContainerInstance/containerGroups" \
  --query id -o tsv)
echo $aci_subnet_id

aci_identity_json=$(az identity create --name $aci_identity_name --resource-group $resource_group_name -o json)
aci_identity_id=$(echo $aci_identity_json | jq -r .id)
aci_identity_object_id=$(echo $aci_identity_json | jq -r .principalId)
echo $aci_identity_id
echo $aci_identity_object_id

az role assignment create \
  --role "AcrPull" \
  --assignee-object-id $aci_identity_object_id \
  --assignee-principal-type ServicePrincipal \
  --scope $acr_id

# Create private endpoint for ACR
# https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link
vnet_spoke_workload_json=$(az network vnet show -g $network_resource_group_name --name vnet-spoke-workload -o json)
vnet_spoke_workload_id=$(echo $vnet_spoke_workload_json | jq -r .id)
echo $vnet_spoke_workload_id

vnet_spoke_workload_subnet_2_json=$(az network vnet subnet show -g $network_resource_group_name --vnet-name vnet-spoke-workload --name snet-2 -o json)
vnet_spoke_workload_subnet_2_id=$(echo $vnet_spoke_workload_subnet_2_json | jq -r .id)
echo $vnet_spoke_workload_subnet_2_id

az network private-dns zone create \
  --resource-group $resource_group_name \
  --name "privatelink.azurecr.io"

az network private-dns link vnet create \
  --resource-group $resource_group_name \
  --zone-name "privatelink.azurecr.io" \
  --name ACR-DNS-Link \
  --virtual-network $vnet_spoke_workload_id \
  --registration-enabled false

az network private-endpoint create \
  --name "pe-$aci_name" \
  --resource-group $resource_group_name \
  --subnet $vnet_spoke_workload_subnet_2_id \
  --private-connection-resource-id $acr_id \
  --group-ids registry \
  --connection-name acr-connection

acr_pe_nic_id=$(az network private-endpoint show \
  --name "pe-$aci_name" \
  --resource-group $resource_group_name \
  --query 'networkInterfaces[0].id' \
  --output tsv)

acr_pe_private_ip=$(az network nic show \
  --ids $acr_pe_nic_id \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry'].privateIPAddress" \
  --output tsv)

acr_pe_data_private_ip=$(az network nic show \
  --ids $acr_pe_nic_id \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$location'].privateIPAddress" \
  --output tsv)
echo $acr_pe_private_ip
echo $acr_pe_data_private_ip

acr_fqdn=$(az network nic show \
  --ids $acr_pe_nic_id \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry'].privateLinkConnectionProperties.fqdns" \
  --output tsv)

acr_data_fqdn=$(az network nic show \
  --ids $acr_pe_nic_id \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$location'].privateLinkConnectionProperties.fqdns" \
  --output tsv)

az network private-dns record-set a create \
  --name $acr_name \
  --zone-name privatelink.azurecr.io \
  --resource-group $resource_group_name

az network private-dns record-set a create \
  --name ${acr_name}.${location}.data \
  --zone-name privatelink.azurecr.io \
  --resource-group $resource_group_name

az network private-dns record-set a add-record \
  --record-set-name $acr_name \
  --zone-name privatelink.azurecr.io \
  --resource-group $resource_group_name \
  --ipv4-address $acr_pe_private_ip

az network private-dns record-set a add-record \
  --record-set-name ${acr_name}.${location}.data \
  --zone-name privatelink.azurecr.io \
  --resource-group $resource_group_name \
  --ipv4-address $acr_pe_data_private_ip

echo $acr_fqdn
echo $acr_data_fqdn

az acr update --name $acr_name --public-network-enabled false

# Various identity options:
# 1. Managed identity for ACI
aci_json=$(az container create \
  --name $aci_name \
  --image "$acr_loginServer/apps/jannemattila/$image" \
  --acr-identity $aci_identity_id \
  --assign-identity $aci_identity_id \
  --ports 80 \
  --cpu 1 \
  --memory 1 \
  --resource-group $resource_group_name \
  --restart-policy Always \
  --ip-address Private \
  --subnet $aci_subnet_id \
  -o json)

# 2. Scope maps and tokens
az acr scope-map create --name developers --registry $acr_name \
  --repository apps \
  content/write content/read \
  --description "Developer access to apps repository"
developer_token_json=$(az acr token create --name developertoken1 --registry $acr_name --scope-map developers -o json)
developer_token_password=$(echo $developer_token_json | jq -r '.credentials.passwords[0].value')

aci_json=$(az container create \
  --name $aci_name \
  --image "$acr_loginServer/apps/jannemattila/$image" \
  --registry-login-server $acr_loginServer \
  --registry-username developertoken1 \
  --registry-password "$developer_token_password" \
  --ports 80 \
  --cpu 1 \
  --memory 1 \
  --resource-group $resource_group_name \
  --restart-policy Always \
  --ip-address Private \
  --subnet $aci_subnet_id \
  -o json)

# 3. Admin credentials
az acr update -n $acr_name --admin-enabled true
acr_password=$(az acr credential show -n $acr_name --query passwords[0].value -o tsv)

aci_json=$(az container create \
  --name $aci_name \
  --image "$acr_loginServer/apps/jannemattila/$image" \
  --registry-login-server $acr_loginServer \
  --registry-username $acr_name \
  --registry-password "$acr_password" \
  --ports 80 \
  --cpu 1 \
  --memory 1 \
  --resource-group $resource_group_name \
  --restart-policy Always \
  --ip-address Private \
  --subnet $aci_subnet_id \
  -o json)

# Test deployment
aci_ip=$(echo $aci_json | jq -r .ipAddress.ip)
echo $aci_ip

az container logs --name $aci_name --resource-group $resource_group_name --follow

# To remove only ACI
az container delete --name $aci_name --resource-group $resource_group_name --yes

#######################
# __   ___ __ ___  
# \ \ / / '_ ` _ \ 
#  \ V /| | | | | |
#   \_/ |_| |_| |_|
# inside management VM 
#######################

aci_ip="http://10.10.2.4"

curl -X POST --data "IPLOOKUP crazfwdemo000010.azurecr.io" "$aci_ip/api/commands"
# IP: 10.10.3.5
curl -X POST --data "NSLOOKUP crazfwdemo000010.azurecr.io" "$aci_ip/api/commands"
# RECORD: crazfwdemo000010.azurecr.io. 60 IN CNAME crazfwdemo000010.privatelink.azurecr.io.

curl -X POST --data "IPLOOKUP crazfwdemo000010.northeurope.data.azurecr.io" "$aci_ip/api/commands"
# IP: 10.10.3.4
curl -X POST --data "NSLOOKUP crazfwdemo000010.northeurope.data.azurecr.io" "$aci_ip/api/commands"
# RECORD: crazfwdemo000010.northeurope.data.azurecr.io. 60 IN CNAME crazfwdemo000010.northeurope.data.privatelink.azurecr.io.

curl -X POST --data "HTTP GET \"https://github.com\"" "$aci_ip/api/commands" # Deny
curl -X POST --data "HTTP GET \"http://10.1.0.4\"" "$aci_ip/api/commands" # Deny

# Exit VM
exit

# Clean up
az group delete --name $resource_group_name -y
