# AKS Demo Deployment with Terraform

This repository contains a Terraform module to provision an Azure Kubernetes Service (AKS) cluster and an Azure SQL database. It also includes the necessary Kubernetes manifest files to deploy a simple web application to the cluster.

The entire process is automated using a single shell script, demonstrating a complete infrastructure-as-code (IaC) and application deployment workflow.

## Project Structure

- `terraform/`: Contains the Terraform code for provisioning the Azure infrastructure.
  - `main.tf`: The main Terraform configuration file.
  - `variables.tf`: Defines the input variables for the Terraform module.
- `kubernetes/`: Contains the Kubernetes manifest files for deploying the application.
  - `deployment.yaml`: Defines the Kubernetes Deployment for the web application.
  - `service.yaml`: Defines the Kubernetes Service (LoadBalancer) to expose the application.
- `app/`: The source code for the simple web application.
  - `Dockerfile`: The instructions to build the Docker image.
- `deploy.sh`: A shell script to automate the end-to-end deployment process.
- `README.md`: This file.

## Prerequisites

- **Azure Account**: A valid Azure subscription.
- **Azure CLI**: Version 2.0 or later.
- **Terraform**: Version 1.0 or later.
- **Docker**: For building the application image.
- **Kubectl**: For interacting with the Kubernetes cluster.

## Deployment Steps

1.  **Customize Script**: Open `deploy.sh` and replace all instances of `<your-acr-name>` with a unique name for your Azure Container Registry.

2.  **Log in to Azure**:
    ```bash
    az login
    ```

3.  **Run the deployment script**:
    The `deploy.sh` script automates all steps: provisioning infrastructure with Terraform, building and pushing the Docker image, and deploying to Kubernetes.
    ```bash
    ./deploy.sh
    ```

4.  **Access the Application**:
    Once the deployment is complete, the script will output the external IP address of your application. You can navigate to this IP in a web browser to view the running app.

## Important Notes & Troubleshooting

* **Azure Free Trial Limitations**: When using an Azure free trial, you may encounter resource provisioning errors. It's often necessary to **limit the node count** and **disable availability zones** in your Terraform configuration.
* **Sensitive Information**: The Terraform files contain a username and password for the SQL database. **Do not use this repository for production workloads.** Consider using Azure Key Vault for managing secrets.
* **State Management**: Executing `terraform apply` commands outside of the `deploy.sh` script can cause your local state to become out of sync with your deployed infrastructure. If this happens, use the following `import` commands to fix the state. **Replace `<subscription-id>` with your actual subscription ID.**

    ```bash
    terraform import azurerm_kubernetes_cluster.aks "/subscriptions/<subscription-id>/resourceGroups/aks-demo-rg/providers/Microsoft.ContainerService/managedClusters/aks-demo-cluster"

    terraform import azurerm_mssql_database.sql_db "/subscriptions/<subscription-id>/resourceGroups/aks-demo-rg/providers/Microsoft.Sql/servers/aks-demo-cluster-sql-server/databases/aks-demo-cluster-sql-db"

    terraform import azurerm_mssql_firewall_rule.aks_firewall_rule "/subscriptions/<subscription-id>/resourceGroups/aks-demo-rg/providers/Microsoft.Sql/servers/aks-demo-cluster-sql-server/firewallRules/aks-firewall-rule"
    ```

* **Docker Platform Mismatch**: It is common for AKS node pools to run on `x86/64 (amd64)` architecture. If you are building Docker images using a Mac with an M1/M2/M3 chip (`arm64`), the image will fail on AKS nodes. Use the following command to build the image for the correct platform:

    ```bash
    docker build --platform linux/amd64 -t aksdemojun0101.azurecr.io/aks-demo-app:latest .
    ```

* **Connection Timed Out**: If you can't access the application after deployment, you may need to add an inbound security rule to the Network Security Group (NSG) associated with your AKS cluster. The NSG is typically found in the resource group prefixed with `MC_`.

    - Go to **Inbound security rules** under the NSG's settings.
    - Click **+ Add**.
    - Configure the rule:
        - **Source:** `Any`
        - **Destination port ranges:** `80`
        - **Protocol:** `TCP`
        - **Action:** `Allow`
        - **Priority:** A number lower than existing rules (e.g., `100`).
        - **Name:** `Allow-HTTP`
    - Click **Add** to create the rule.

## Handy `kubectl` Commands

Here are some useful commands for managing your Kubernetes cluster:

-   `kubectl apply -f deployment.yaml service.yaml`: Apply your Kubernetes manifests.
-   `kubectl get service <service name> -o wide`: Get detailed service information.
-   `kubectl get pods`: List all pods in the cluster.
-   `kubectl rollout restart deployment/<deployment name>`: Force a new deployment.
-   `kubectl describe pod <pod name>`: View detailed information and events for a pod.
-   `kubectl delete pod <pod name>`: Delete a pod.