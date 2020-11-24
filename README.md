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
# This command downloads credentials and configures the Kubernetes CLI to use them
az aks get-credentials --resource-group AZ-RG-K8S --name tp-k8s-cluster

# Admin namespace
kubectl apply -f admin-namespace/00_admin-namespace.yml
kubectl apply -f admin-namespace/10_quota.yml

# Data namespace
kubectl apply -f data-namespace/00_data-namespace.yml
kubectl apply -f data-namespace/10_quota.yml

# Web namespace
kubectl apply -f web-namespace/00_web-namespace.yml
kubectl apply -f web-namespace/10_quota.yml
```