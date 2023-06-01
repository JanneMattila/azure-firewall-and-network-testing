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
azuread_admin_group_contains="janneops"

workload_aks_name="aks-workload"
workload_acr_name="cmyaksworkload0000010"
workload_workspace_name="log-myaksworkload"
workload_subnet_aks_name="snet-1"
workload_vnet_name="vnet-spoke-workload"
workload_cluster_identity_name="id-workload-cluster"
workload_kubelet_identity_name="id-workload-kubelet"

other_workload_aks_name="aks-other-workload"
other_workload_vnet_name="vnet-spoke-other-workload"
other_workload_subnet_aks_name="snet-1"
other_workload_cluster_identity_name="id-other-workload-cluster"
other_workload_kubelet_identity_name="id-other-workload-kubelet"

resource_group_name="rg-azure-firewall-and-network-testing-workloads"

network_resource_group_name="rg-azure-firewall-and-network-testing"

location="northeurope"

#################################
#   ____                _
#  / ___|_ __ ___  __ _| |_ ___
# | |   | '__/ _ \/ _` | __/ _ \
# | |___| | |  __/ (_| | ||  __/
#  \____|_|  \___|\__,_|\__\___|
# Create workload Private AKS
#################################

az group create -l $location -n $resource_group_name -o table

azuread_admin_group_id=$(az ad group list --display-name $azuread_admin_group_contains --query [].id -o tsv)
echo $azuread_admin_group_id

# TODO: Use Premium and create private endpoint to snet-2
workload_acr_json=$(az acr create -l $location -g $resource_group_name -n $workload_acr_name --sku Basic -o json)
echo $workload_acr_json
workload_acr_loginServer=$(echo $workload_acr_json | jq -r .loginServer)
workload_acr_id=$(echo $workload_acr_json | jq -r .id)
echo $workload_acr_loginServer
echo $workload_acr_id

workload_workspace_id=$(az monitor log-analytics workspace create -g $resource_group_name -n $workload_workspace_name --query id -o tsv)
echo $workload_workspace_id

workload_subnet_aks_id=$(az network vnet subnet show -g $network_resource_group_name --vnet-name $workload_vnet_name \
  --name $workload_subnet_aks_name --query id -o tsv)
echo $workload_subnet_aks_id

workload_cluster_identity_json=$(az identity create --name $workload_cluster_identity_name --resource-group $resource_group_name -o json)
workload_kubelet_identity_json=$(az identity create --name $workload_kubelet_identity_name --resource-group $resource_group_name -o json)
workload_cluster_identity_id=$(echo $workload_cluster_identity_json | jq -r .id)
workload_kubelet_identity_id=$(echo $workload_kubelet_identity_json | jq -r .id)
workload_kubelet_identity_object_id=$(echo $workload_kubelet_identity_json | jq -r .principalId)
echo $workload_cluster_identity_id
echo $workload_kubelet_identity_id
echo $workload_kubelet_identity_object_id

az aks get-versions -l $location -o table

workload_aks_json=$(az aks create -g $resource_group_name -n $workload_aks_name \
 --tier standard \
 --max-pods 50 --network-plugin azure \
 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 4 \
 --node-vm-size Standard_D8ds_v4 \
 --node-osdisk-type Ephemeral \
 --enable-private-cluster \
 --private-dns-zone None \
 --kubernetes-version 1.25.5 \
 --enable-addons monitoring \
 --enable-aad \
 --enable-azure-rbac \
 --disable-local-accounts \
 --no-ssh-key \
 --aad-admin-group-object-ids $azuread_admin_group_id \
 --workspace-resource-id $workload_workspace_id \
 --attach-acr $workload_acr_id \
 --load-balancer-sku standard \
 --vnet-subnet-id $workload_subnet_aks_id \
 --assign-identity $workload_cluster_identity_id \
 --assign-kubelet-identity $workload_kubelet_identity_id \
 -o json)

echo $workload_aks_json

#######################
# __   ___ __ ___  
# \ \ / / '_ ` _ \ 
#  \ V /| | | | | |
#   \_/ |_| |_| |_|
# inside management VM 
#######################

workload_aks_name="aks-workload"
resource_group_name="rg-azure-firewall-and-network-testing-workloads"

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --tenant 8a35e8cd-119a-4446-b762-5002cf925b1d -o none

az account show

sudo az aks install-cli

az aks get-credentials -n $workload_aks_name -g $resource_group_name --overwrite-existing

kubelogin convert-kubeconfig -l azurecli

kubectl get nodes

git clone https://github.com/JanneMattila/aks-workshop.git
cd aks-workshop

ls -lF

kubectl apply -f network-app

kubectl apply -f storage-app/00-namespace.yaml
kubectl apply -f storage-app/03-service.yaml
kubectl apply -f storage-app/10-azuredisk-sc.yaml
kubectl apply -f storage-app/11-persistent-volume-claim-disk.yaml
kubectl apply -f storage-app/12-statefulset.yaml

kubectl get pvc -n storage-app
kubectl describe pvc premiumdisk-pvc -n storage-app
kubectl describe pvc premiumdisk-storage-app-deployment-0 -n storage-app
kubectl get pv -n storage-app
kubectl get pods -n storage-app
kubectl describe pods -n storage-app

# Flow limits and active connections recommendations
# https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput#network-flow-limits

az group delete --name $resource_group_name -y
