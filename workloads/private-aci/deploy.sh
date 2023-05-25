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

aci_json=$(az container create \
  --name $aci_name \
  --image "$acr_loginServer/apps/$image" \
  --acr-identity $aci_identity_id \
  --assign-identity $aci_identity_id \
  --registry-login-server $acr_loginServer \
  --ports 80 \
  --cpu 1 \
  --memory 1 \
  --resource-group $resource_group_name \
  --restart-policy Always \
  --ip-address Private \
  --subnet $aci_subnet_id \
  -o json)

aci_ip=$(echo $aci_json | jq -r .ipAddress.ip)
echo $aci_ip
