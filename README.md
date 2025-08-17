# AKS Demo Deployment with Terraform & Azure DevOps

This repository contains a Terraform module to provision an Azure Kubernetes Service (AKS) cluster and an Azure SQL database. It also includes the necessary Kubernetes manifest files to deploy a simple web application to the cluster.

The entire process is automated using Azure DevOps Pipelines, demonstrating a complete infrastructure-as-code (IaC) and CI/CD workflow. The project is structured as a monorepo to separate infrastructure, application, and deployment concerns.

## Project Structure

- **`.azdo/`**: Contains the Azure DevOps pipeline YAML files.
  - `azure-pipelines-infra.yml`: The pipeline to provision Azure infrastructure with Terraform.
  - `azure-pipelines-app.yml`: The pipeline to deploy the application to an AKS cluster.
- **`infra/`**: Contains the reusable Terraform code for provisioning the AKS cluster and Azure SQL.
- **`app/`**: Contains the source code for the simple web application and its `Dockerfile`.
- **`deploy/`**: Contains the Kubernetes manifests and scripts for deploying the application.
- **`README.md`**: This file.
![Architecture Diagram](assets/architecture_diagram.png)
## Prerequisites

-   An **Azure DevOps Organization** with a valid parallelism grant.
-   **Azure CLI** installed and configured.
-   **Docker** and **kubectl** installed for local testing.

---

## For Platform Engineers 🛠️

### How to Build, Maintain, and Roll Out Changes

As a platform engineer, your primary responsibility is to manage the hosting environment.

#### 1. Initial Setup

Set up the core resources and connections in Azure DevOps once.

-   **Service Connection**: Go to **Project settings > Service connections** and create an **Azure Resource Manager** connection. Name it `aks-demo-service-connection`. This provides the pipelines with the permissions to manage Azure resources.
-   **Variable Groups**: Go to **Pipelines > Library** and create a new **Variable Group** for each environment (e.g., `aks-demo-dev-vars`). Store your environment-specific configuration here, including `aks_cluster_name`, `resource_group_name`, `sql_username`, and `sql_password`.
-   **Terraform Backend**: Create a dedicated Azure Storage Account to store the Terraform state files. This ensures state locking and collaboration.

#### 2. Provisioning Infrastructure

The `azure-pipelines-infra.yml` pipeline automates the provisioning process.

-   **Create the Pipeline**: In Azure DevOps, create a new pipeline from the `infra` YAML file on your feature branch.
-   **Run the Pipeline**: Manually trigger the pipeline and select the desired variable group (e.g., `aks-demo-dev-vars`). The pipeline will provision all necessary infrastructure for that environment.

#### 3. Rolling Out Changes

To make changes to the infrastructure, update the Terraform files in the `infra/` folder.

-   Commit the changes to your Git branch.
-   Trigger the `azure-pipelines-infra.yml` pipeline, which will apply the changes to your existing infrastructure.

![Architecture Diagram](assets/workflow_diagram.png)

### How to Onboard New Teams 🚀

To onboard a new team, you simply repeat the provisioning process with a new configuration.

1.  **Create a New Variable Group**: Create a new Variable Group in the Azure DevOps library (e.g., `team-alpha-prod-vars`) with the specific names and location for the new team's cluster.
2.  **Provision the New Cluster**: Run the `azure-pipelines-infra.yml` pipeline manually and select the new variable group. This creates an isolated cluster for the new team.
3.  **Provide Credentials**: Give the application team credentials (e.g., a Service Principal) with permissions to push Docker images to your Azure Container Registry.

---

## For Application Engineers 💻

### How to Build & Deploy on the Platform

Your responsibility is to build and deploy your application to the platform provided by the platform team.

#### 1. Building the Docker Image

The `app/Dockerfile` in this repository is designed to build your application image.

-   To build and test the image locally, use the following command. Note the `--platform` flag to ensure compatibility with AKS nodes.
    ```bash
    docker build --platform linux/amd64 -t <your-acr-name>.azurecr.io/aks-demo-app:latest .
    ```
-   Push the image to the Azure Container Registry provided by the platform team.
    ```bash
    docker push <your-acr-name>.azurecr.io/aks-demo-app:latest
    ```

#### 2. Setting Up the CI/CD Pipeline

The platform team will provide you with a deployment pipeline based on `azure-pipelines-app.yml`.

-   **Get Access**: The platform team will give you a Service Connection to the hosting environment.
-   **Link the Pipeline**: In Azure DevOps, create a new pipeline that points to the `azure-pipelines-app.yml` file. Link it to the Service Connection and Variable Group provided by the platform team.

Once set up, you can trigger this pipeline to deploy your application to the cluster.

### Useful `kubectl` Commands

-   `kubectl get service -o wide`: Get detailed service information, including the external IP.
-   `kubectl get pods`: List all pods in the cluster.
-   `kubectl rollout restart deployment/<deployment-name>`: Force a new deployment.
-   `kubectl describe pod <pod-name>`: View detailed information and events for a pod.
-   `kubectl logs <pod-name>`: View the logs from a container in a pod.