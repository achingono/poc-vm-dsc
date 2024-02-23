# POC: Azure Virtual Machines deployment through DSC

This repository demonstrates a sample IIS application running in an [Azure Virtual Machine](https://azure.microsoft.com/en-us/products/virtual-machines/), deployed through [Azure Desired State Configuration](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-overview)

## Features

- The application is hosted in Windows [Virtual Machines](https://azure.microsoft.com/en-us/products/virtual-machines/), an on-demand, scalable cloud computing Azure service with allocation of hardware, including CPU cores, memory, hard drives, network interfaces, and other devices to run a wide range of operating systems, applications, and workloads in the Azure cloud environment.  

- The application is deployed through the [Azure Desired State Configuration (DSC)](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-overview) extension which uses the Azure VM Extension framework to deliver, enact, and report on DSC configurations running on Azure VMs.