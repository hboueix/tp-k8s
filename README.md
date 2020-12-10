# TP Kubernetes

3 namespaces: 
- data-namespace:
	- KubeDB
	- Monitoring
- web-namespace:
	- Wordpress repliqué
	- Registry + GUI Web
- admin-namespace:
	- RBAC
	- OICD

## Install HELM

```bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## How to
```bash
# Create Azure AD groups
az ad group create --display-name myAKSAdminGroup --mail-nickname myAKSAdminGroup
az ad group create --display-name AKSClusterAdmin --mail-nickname AKSClusterAdmin
az ad group create --display-name AKSDevGroup --mail-nickname AKSDevGroup
az ad group create --display-name AKSSysOpsGroup --mail-nickname AKSSysOpsGroup

# Get AKS group IDs
az ad group list --filter "displayname eq 'myAKSAdminGroup'" -o table
adminGroupId=f7274dad-4050-4c4a-922d-ecfff4bae6bd
adminClusterId=6785b782-e59c-41de-badf-aca32570be54
devId=ff1c722d-b967-4a26-9fb1-c811eaa64610
sysOpsId=8cb02ce7-2ddd-4c45-b393-418f8003f241

# Create ressources group and AKS cluster
az group create --name AZ-RG-K8S --location centralfrance
az aks create -g AZ-RG-K8S -n AZ-K8S-cluster --node-count 1 --node-vm-size standard_b2s --enable-aad --aad-admin-group-object-ids $adminGroupId 
#[--aad-tenant-id <id>]

# Add users to AKS admin group
az ad group member add --group myAKSAdminGroup --member-id 00ccca65-85e3-4ca8-aacc-bf509d518bbf # hugo.boueix
az ad group member add --group myAKSAdminGroup --member-id 91131d50-771a-49cf-8bde-11ef1d69c583 # vivien.mouret

# Create role assignment 
ressourceScope=/subscriptions/f9f4598f-67eb-4c07-874b-dff85e792422/resourcegroups/AZ-RG-K8S/providers/Microsoft.ContainerService/managedClusters/AZ-K8S-cluster
## Cluster admin
az role assignment create \
  --assignee $adminClusterId \
  --role "Azure Kubernetes Service Cluster Admin Role" \
  --scope $ressourceScope
az role assignment create \
  --assignee $adminClusterId \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope $ressourceScope
## Dev
az role assignment create \
  --assignee $devId \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope $ressourceScope
az role assignment create \
  --assignee $devId \
  --role "Azure Kubernetes Service RBAC Writer" \
  --scope $ressourceScope
## SysOps
az role assignment create \
  --assignee $sysOpsId \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope $ressourceScope
az role assignment create \
  --assignee $sysOpsId \
  --role "Azure Kubernetes Service RBAC Writer" \
  --scope $ressourceScope

# This command downloads credentials and configures the Kubernetes CLI to use them
az aks get-credentials --resource-group AZ-RG-K8S --name AZ-K8S-cluster

#
# Namespaces
#
## Data
kubectl apply -f namespaces/00_data-namespace.yml
## Web
kubectl apply -f namespaces/10_web-namespace.yml

#
# Workloads
#
## kubeDB
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm search repo appscode/kubedb
helm install kubedb-operator appscode/kubedb --version 0.15.1 \
  --namespace kube-system
kubectl get crds -l app=kubedb -w
helm install kubedb-catalog appscode/kubedb-catalog --version 0.15.1 \
  --namespace kube-system
    # replace install -> upgrade if needed

kubectl create configmap -n data-namespace mysql-init-script \
  --from-file=./scripts/mysql-init-script.sql

kubectl apply -f workloads/20_mysql_database.yml

kubectl exec -it -n data-namespace mysql-0 -- mysql -u root -p -e "ALTER USER wordpress IDENTIFIED WITH mysql_native_password BY 'M0td3p4ss3';"

az aks enable-addons --resource-group AZ-RG-K8S --name AZ-K8S-cluster --addons http_application_routing
az aks show --resource-group AZ-RG-K8S --name AZ-K8S-cluster --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table

kubectl apply -f wordloads/30_wordpress.yml
```