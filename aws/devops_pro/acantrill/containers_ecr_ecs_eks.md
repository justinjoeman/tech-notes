# Containers, ECR, ECS, EKS

## Containers
**What is a virtual machine?**
A virtual machine is basically a "machine within a machine, without its own physical infrastructure". You normally have a host which has some sort of virtualisation OS installed on it. You can then configure it to allocate a portion of the host resources to create a virtual machine with its own operating system as if it was an isolated resource like a laptop. Each new VM will have its own allocated space and own OS.

**What is a container?**
Containers are like virtual machines, but are a much more lightweight unit of software that packages code and dependencies to applications can run quicker. A `container engine` sits on top of the host to run the containers. Each container has its own allocated resource.

### What is the difference between a container and virtual machine?
* The main difference is would be that a VM installs the operating system as well as an application to run with each one. So the OS might take up a lot more resource compared to a container. 
* Container doesn't need to install its own OS each time to run. It runs as a process on the host container therefore "sharing the OS kernal of the host"
* Container separation / isolation comes from C-Groups and namespaces
* Virtual machines virtualize an entire machine down to the hardware layers and containers only virtualize software layers above the operating system level

## ECS
### Concepts
* 2 modes 
    * **ECS** which uses EC2 to run your ECS containers on which you manage 
    * **Fargate** mode where AWS manage the hosts so you only need to define the container definitions and not have to worry about the rest of the infrastructure.
* A managed container based compute service
* **Container definition** - config on container image and settings about the container you want to run. Image & ports
* **Task definition** - can contain 1 or more containers. Similar to a pod where it might represent the application as a whole. Stores what container definitions are used to make uo that application. Store resources like CPU / Memory / networking mode / compatability and the task role.
* **Task role** - the IAM role that can be assumed to give your containers permissions to access resources within AWS account
* Doesn't scale on its own and isn't *highly available* by default
* **Service definition** - Define details on how we want a task to scale. How many replicas of the task and even deploy a load balancer infront of the service to spread the load.
    * Use a service to provide the **high availability** and **scalability**

### ECS Cluster mode

#### EC2 mode
* ECS management components (schedulingOrchestration, ClusterManager, PlacementEngine)
* ECS cluster is created within a VPC in your account. Can benefit from the different AZs.
* You create a cluster, attached to an ASG.
* We are responsible for the EC2 hosts (billed for servers running regardless of any containers running on them)
* In thos mode ECS handles number of tasks running across the nodes
* Admin need to manage the capacity of the cluster (eg make sure enough resources to handle max number of containers running)
* Can make use of reserved instances / spot pricing etc for example

#### Fargate mode
* Don't have to manage any servers, simply for time / resources containers are actually running
* Containers hosted on a **shared fargate infrastructure** but **no visiblity** of other customers
* Tasks / services injected into the VPC and picks up an ENI and then work like any other VPC resource

### EC2 vs ECS (EC2) vs Fargate
* If you use containers, use ECS
* Generally pick ECS (EC2 mode) if you have a **large consistent workload** and are **price conscious** - to make use of reserved instances etc
* If overhead conscious regardless of workload - fargate is the better option.
* Small / burst / batch / periodic workloads - fargate as you only pay for what you use just like Lambda without worrying about managing infrastructure / admin overhead

## Kubernetes overview
* Open source container orchestration system to automate deployment, scaling and management of containerised applicatiopns
* Cloud agnostic - can use on premise or in any cloud platform. Some Cloud providers have their own version where they have made changes of added applications to assist with integration to their platform eg EKS
* Generally highly availabie cluster of compute resources that are organised to work as one unit
* **Control plane** manages / orchestrates cluster scheduling, applications, scaling and deployment
    * `kube-apiserver` - frontend for the control plane. Nodes and other cluster elements interact with this. Can be scaled horizontally for HA and performance
    * `etcd` - highly available key/value store that acts as the main backing store for the cluster
    * `kube-scheduler` - identifies any pods in the cluster that doens't have a node assigned and assigns a node based on things like resource requirments, labels, affinity etc
    * `kube-controller-manager` - controls cluster processes such as 
        * `node controller` - monitoring and responding to node outages
        * `job controller` - one off tasks (jobs) -> PODS
        * `endpoint controller` - populates endpoints (services <-> pods)
        * `service account & token controllers` - Accounts/API tokens
    * `cloud-controller-manager` (optional) - provide cloud specific control logic. For example allows you to link kubernetes with the providers apis in AWS/Azure/GCP etc
    * `kube-proxy` - runs on every node and is a network proxy. Coordinates networking with the control plane. Helps implement services and configure rules allowing communications with pods from inside and outside the cluster
* **Nodes** - virtual or physical servers that function as workers within a cluster. Containers run on the nodes
    * **container runtime** (docker or containerd) - will run on the nodes handling container operations
    * **kubelet** - agent to interact with the cluster control plane using he kubernetes api
* **Pods** - smallest unit of computing. 1 or more containers that are tightly coupled together to run an application. Eg 1 container to get config files, 2nd container in pod to use config file to run application


## EKS
* AWS managed kubernetes
* Can run on AWS itself, Outposts, EKS anywhere, EKS distro
* Control plane scales and runs on multiple AZs
* Integrates with other AWS services eg ECR, ELB, IAM, VPC etc
* EKS cluster = EKS control plane & EKS Nodes
* etcd distributed across multi AZs
* Nodes - can be self managed, part of a managed node group or fargate pods
* Deciding between self managed, managed node groups and fargate will be based on requirements
    * If you need windows pods, GPU, inferentia, bottlerocket, outpots, local zones - then need to check node type being used and make sure capable of using these features
* Storage by default is ephemeral (non persistent) 
* Can attach storage providers such as EBS / EFS / FSx Lustre, FSz for NetApp ONTAP if persistent storage is required
* Control plane deployed into AWS Managed VPC -> Control plane ENIs injected into customer VPC so the nodes can communicate with it via **kube-api traffic**
    * EKS admin endpoint can also be a public endpoint into AWS Managed VPC to admin your cluster