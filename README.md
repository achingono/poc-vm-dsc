# POC: Azure Virtual Machines deployment through DSC

This repository demonstrates a sample IIS application running in an [Azure Virtual Machine](https://azure.microsoft.com/en-us/products/virtual-machines/), deployed through [Azure Desired State Configuration](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-overview)

[![Provision Infrastructure](https://github.com/achingono/poc-vm-dsc/actions/workflows/provision.yaml/badge.svg)](https://github.com/achingono/poc-vm-dsc/actions/workflows/provision.yaml)

## Features

- The application is hosted in Windows [Virtual Machines](https://azure.microsoft.com/en-us/products/virtual-machines/), an on-demand, scalable cloud computing Azure service with allocation of hardware, including CPU cores, memory, hard drives, network interfaces, and other devices to run a wide range of operating systems, applications, and workloads in the Azure cloud environment.  

- The application is deployed through the [Azure Desired State Configuration (DSC)](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-overview) extension which uses the Azure VM Extension framework to deliver, enact, and report on DSC configurations running on Azure VMs.

## Additional Azure Resources

- **[Azure resource groups](https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal)** are logical containers for Azure resources. You use a single resource group to structure everything related to this solution in the Azure portal.

- **[Azure Virtual Network](https://azure.microsoft.com/en-us/products/virtual-network/)** is a service that provides the fundamental building block for your private network in Azure. An instance of the service (a virtual network) enables many types of Azure resources to securely communicate with each other, the internet, and on-premises networks.

- **[Azure Storage Account](https://docs.microsoft.com/azure/storage/common/storage-account-overview)** a cloud-based storage solution provided by Microsoft Azure. It allows you to store and retrieve large amounts of unstructured data such as files, blobs, tables, and queues. It offers high availability, durability, and scalability, making it suitable for a wide range of applications. 

- **[PowerShell DSC Extension](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-windows)** a Virtual Machine extension that uploads and applies a PowerShell DSC Configuration on an Azure VM. The DSC Extension calls into PowerShell DSC to enact the received DSC configuration on the VM.

- **[Web Deploy](https://www.iis.net/downloads/microsoft/web-deploy)** an IIS extension that simplifies deployment of Web applications and Web sites to IIS servers. Web Deploy enables packaging Web application content, configuration, databases and any other artifacts like registry, GAC assemblies etc., which can be used for storage or redeployment.

## Benefits of this Architecture Sample
The implementation in this workspace has several benefits:

1. **Automation**: By using PowerShell DSC, Bicep, and GitHub Actions, the code enables automation of the provisioning and configuration of a virtual machine and the deployment of a web application. This automation saves time and effort by eliminating the need for manual setup and deployment processes.

2. **Consistency**: With the use of PowerShell DSC and Bicep, the implementation ensures consistent configuration and deployment across different environments. This consistency helps in avoiding configuration drift and ensures that the application behaves the same way in all environments.

3. **Scalability**: The code can be easily scaled to provision and configure multiple virtual machines and deploy multiple web applications. This scalability is particularly useful in scenarios where there is a need to deploy the application across multiple instances or environments.

4. **Version Control**: By utilizing GitHub Actions, the implementation benefits from version control capabilities. This allows for tracking changes, rolling back to previous versions, and collaborating with other team members effectively.

5. **Reproducibility**: The code provides a reproducible process for provisioning and deploying the web application. This means that the same code can be used to recreate the environment and deploy the application in a consistent manner, even if the environment needs to be rebuilt or replicated.

6. **Flexibility**: PowerShell DSC and Bicep offer flexibility in terms of customizing the configuration and deployment process. They provide a wide range of options and configurations that can be tailored to specific requirements.

Overall, the implementation in this workspace combines the power of PowerShell DSC, Bicep, and GitHub Actions to automate, standardize, and streamline the provisioning and deployment process, resulting in improved efficiency, consistency, and scalability.

## Getting Started

The deployment process involves the following steps:
1. Provision the architecture using Bicep
1. Create application deployment package
1. Publish application deployment package

### Prerequisites

1. Local bash shell with Azure CLI or [Azure Cloud Shell](https://ms.portal.azure.com/#cloudshell/)
1. Azure Subscription. [Create one for free](https://azure.microsoft.com/free/).
1. Clone or fork of this repository.

### QuickStart

A bash script is included for quickly provisioning a fully functional environment in Azure. The script requires the following parameters:

```
-n: The deployment name.
-l: The region where resources will be deployed.
-c: A unique string that will ensure all resources provisioned are globally unique.
-u: The virtual machine administrator username.
-p: The virtual machine administrator password.
-v: The deployment version used for DSC and WebDeploy packages.
```
> **NOTE:** Please refer to the [Resource Name Rules](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftweb) to learn more about globally unique resources.

Follow the steps below to quickly deploy using the bash script:

1. Clone the repository to local machine.
    ```
    git clone https://github.com/achingono/poc-vm-dsc.git
    ```
1. Switch to the cloned folder
    ```
    cd poc-vm-dsc
    ```

1. Make the bash script executable
    ```
    chmod +x ./deploy.sh
    ```

1. Login to Azure and ensure the correct subscription is selected
    ```
    az login
    az account set --subscription <subscription id>
    az account show
    ```

1. Run the script and provide required parameters
    ```
    ./deploy.sh -n dsc -c poc -l eastus2  -u azureuser -p <secure password> -v 1.0
    ```
    In the above command, `dsc` is the name of the environment, and `poc` is the variant. This generates a resource group named `rg-dsc-poc-eastus2`.

### GitHub Actions Option

GitHub workflows are included for deploying the solution to Azure.

To run the workflows, follow these steps:

1. Fork the repo
1. Create three environments:
    - `Production`: Commits to the `master` or `main` branch will trigger deployments to this environment.
    - `Development`: Commits to the `dev` or `develop` branch will trigger deployments to this environment.
    - `Features`: Commits to any branch under `features/` will trigger deployments to this environment.
1. Create the following secrets:
    - `AZURE_CREDENTIALS`: This secret will be used by GitHub actions to authenticate with Azure. Follow the instructions [here](https://github.com/marketplace/actions/azure-login#login-with-a-service-principal-secret) to login using Azure Service Principal with a secret.
    - `AZURE_PASSWORD`: This is the password used to login to the virtual machine
    - `AZURE_USERNAME`: This is the username for logging in to the virtual machine
    - `DECRYPTION_KEY`: This is the decryption key applied to the `<machineKey />` section of the `web.config` file.
    - `VALIDATION_KEY`: This is the validation key applied to the `<machineKey />` section of the `web.config` file.
1. Create the following environment variables:
    - `AZURE_LOCATION`: This is the Azure region where resources will be deployed
    - `AZURE_NAME`: This is the name that will be appended to Azure resources
    - `AZURE_SUFFIX`: This is a unique code that will be appended to Azure resources
1. Go to [Actions](../actions/)
1. Click on the `Provision Infrastructure` action
1. Click on `Run workflow` and select a branch

## Cleanup

Clean up the deployment by deleting the single resource group that contains the entire infrastructure.

> **WARNING:** This will delete ALL the resources inside the resource group.

1. Make the bash script executable
    ```
    chmod +x ./destroy.sh
    ```

2. Login to Azure and ensure the correct subscription is selected
    ```
    az login
    az account set --subscription <subscription id>
    az account show
    ```

3. Run the script and provide required parameters
    ```
    ./destroy.sh -n dsc -c poc -l eastus2
    ```