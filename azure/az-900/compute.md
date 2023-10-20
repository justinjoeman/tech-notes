# Compute in Azure

## Virtual Machines
* manage everything except the hardware
* Use azure portal / cli / sdk to manage VMs
* Azure blueprints can be used to make VMs comply with company guidelines
* Azure recommended improvements 
* Can choose number of configs and OS
* Pricing - calculated hourly. More resources = higher cost per hour
* Integral part of a number of Azure services

## Scale sets
* Manage a group of identitcal load balanced VMs
* Can scale in / out based on resource utilisation or on a schedule (autoscaling)
* Used to achieve high availability
* Run upto 1000 VMs per scaleset
* No extra cost - only pay per VM, storage and networking costs associated with VMs

## App Services
* A fully managed platform - servers, network and storage handled by Azure
* Web Apps - website and online applications hosted on azures managed platform
    * Runs on both windows and linux
    * Support number of languages such as .NET, Node.js, Python
    * Azure integration for easier deployment
    * Autoscaling and load balancing
* Web Apps for containers - Deploy and run existing containerised apps in azure
    * All dependencies shipped inside container
    * Deploy anywhere for consistent experience
* API Apps - expose,host and connect your data backend
    * an application programming interface
    * No GUI
    * Use a range of programming languages

## Azure Container Instances
* Container images are deployed to Azure Container Instances
* On demand - no need to manage virtual machines
* Works with tool of choice eg Azure portal, CLI or Powershell

## Azure Kubernetes service
* Azures offering of Kubernetes
* Replicate container architectures
* Managed service, get IAM, elastic provisoning and more
* Global reach
* Container images can come from Azure Container Registry (ACR)
    * Feeds container images to ACI and AKS
    * Manages files and artifacts for containers
    * Use Azure Identity and security features

## Azure Virtual Desktop
* Deploy a virtual desktop that anyone with an internet can connect to
* Reuse Windows 10 licenses
* Multiple users can use the same VM instance
* Access anywhere with an internet browser
* Use Azure storage to secure data

## Azure functions
* Think serverless - simply execute code logic, similar to AWS Lambda