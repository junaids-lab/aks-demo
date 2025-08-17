#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Replace with your own values
RESOURCE_GROUP_NAME="aks-demo-rg"
AKS_CLUSTER_NAME="aks-demo-cluster"
ACR_NAME="aksdemojun0101" # Must be globally unique

# --- 1. Provision Infrastructure with Terraform ---
echo "--- Initializing and applying Terraform configuration ---"
echo "NOTE: This will provision an Azure SQL Database (S0 DTU)"
cd terraform
terraform init
terraform apply -auto-approve
cd ..

# --- 2. Build and Push Docker Image ---
echo "--- Building and pushing Docker image ---"

# Check if Azure Container Registry exists, if not, create it
if ! az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP_NAME &> /dev/null; then
  echo "Azure Container Registry '$ACR_NAME' not found. Creating it..."
  az acr create --resource-group $RESOURCE_GROUP_NAME --name $ACR_NAME --sku Basic
fi

# Log in to ACR
az acr login --name $ACR_NAME

# Tag and push the image
docker build --platform linux/amd64 -t $ACR_NAME.azurecr.io/aks-demo-app:latest .
docker push $ACR_NAME.azurecr.io/aks-demo-app:latest

# --- 3. Connect to AKS and Deploy Application ---
echo "--- Getting AKS credentials and deploying application ---"

# Get AKS credentials
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --overwrite-existing

# Update the Kubernetes manifest with the correct image tag
sed "s|<your-acr-name>|$ACR_NAME|g" deployment.yaml > deployment-temp.yaml

# Apply the Kubernetes manifests
kubectl apply -f deployment-temp.yaml
kubectl apply -f service.yaml

# Clean up temporary file
rm deployment-temp.yaml

echo "--- Deployment complete! ---"
echo "--- Wait for the LoadBalancer to get an external IP. Run 'kubectl get service aks-demo-service' to check. ---"