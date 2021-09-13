# Cloud-Native-DevLab

This is a collection of PowerShell, Azure Cli and YAML for setting up your own Kubernetes cluster at home based on Azure Kubernetes Service (AKS).

The purpose of this is to provide a quick and easy way for setting up a cluster that represents a production-like developer environment for a Microsoft infra stack. (Workloads and general k8s configs are of course generic.)

In addition to a simple working AKS cluster there are also a number of extra features available. These are often used with Kubernetes for extra features, security, etc.

This is based on Azure Stack HCI AKS:  
[https://docs.microsoft.com/en-us/azure-stack/aks-hci/](https://docs.microsoft.com/en-us/azure-stack/aks-hci/)  

A few notes on this guide:
*  The focus is as much automation as possible. You will need to supply values specific to your environment, but apart from that as few wizards as possible is the goal.
* The bootstrap section is what I consider the bare minimum to get things running. Other sections are optional, and can be adapted to your liking. Don't need it? Don't use it.
* The guide / scripts will include explanations where needed, but MS Docs is currently where you need to go for more detailed instructions and architectural guidance.
* I try to ensure accuracy, but this is a fast moving target. A PowerShell cmdlet might change, a component gets a version bump, etc. If you find errors submit a PR (if you know the fix), or an issue and I'll take a look at it.
* The design goal of these instructions leans towards tearing down and rebuild the cluster; not enabling easy upgradeability. (There are no blockers for such, but not a responsibility of the guide that it will work flawlessly.)

The structure of this guide is as follows:  

### Sections:  
_01_Bootstrap_  
We install the necessary tooling and install a management and a workload cluster.

_02_Monitoring_  
We install Prometheus, Grafana and Jaeger. Loadbalancers for all three are also created (if you want), but not DNS names.

_03_Azure_Policy_
We create a service principal (with a "Policy Writer" role) and use this to enable Azure Policy in our cluster.

## Q & A
Q: Why not Docker Desktop, minikube, or a number of other distros?  
A: The choice of AKS is an opinionated one with the thinking behind it being that you want your production workloads to end up in an Azure Kubernetes Service cluster.

Q: So, why not just run in the cloud altogether?  
A: Once again - a choice. If you already have access to the necessary hardware this can be cheaper than running on Azure, and you get more control of the entire stack than the cloud version.

Q: What do I need to run this specs-wise?  
A: I have tested this on a single node HPE Proliant Microserver Gen10 Plus with 32 GB RAM and 1TB NVMe SSD running Windows Server 2022 RTM. You don't want less than 32 GB RAM.

I have also tested on a dual-node Azure Stack HCI cluster (Microservers with 64 GB RAM each). Do note that if you want to use Storage Spaces Direct (S2D) you will want 1 NVMe drive and 4 SSDs in each node at a minimum for a bare-metal installation.

It is possible to run everything in Virtual Machines if your hardware supports nested virtualization.

Q: Can I expose the cluster on the internet?  
A: Depends on your ISP. The defaults here will set you up with a fully private cluster, but if you have a NIC connected to a WAN and provide static IPs you should be good to go. Reverse proxies and firewalls should also work, but I have not verified this.