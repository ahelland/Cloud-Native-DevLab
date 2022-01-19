## 08_Flux

Provisioning applications and configuration through the use of yaml-files and kubectl is a quick and easy way to test during development, but it is less flexible if you want to move to a production grade setup. This is a lab setup so the concern is not to remove the possibility for manually handling yaml, but even for a lab setup you can make things easier by using a GitOps approach for components you're not actively working on.

GitOps means that you interact with a Git repo and as if by "magic" what you check in will be deployed to your Kubernetes cluster. It is possible to handle both configuration and deployment of applications this way.

Microsoft provides built-in support for the Flux project (popular GitOps tool) both in Azure Kubernetes Service and AKS on Azure Stack HCI.  
More info on Flux here: [https://fluxcd.io/](https://fluxcd.io/)

Flux installs components inside your cluster that are able to listen to Git repos and reach out to pull in (and customize) yaml definitions that are subsequently applied. Repos will need to be added, but the rest is handled automatically.

The instructions provided in this repo will create a Flux configuration for installing a sample app with an accompanying yaml specification. If the repo is updated Flux will automatically pull in the changes.

Links to more info from Microsoft:  
[https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2)  
[https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-gitops-flux2-ci-cd](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-gitops-flux2-ci-cd)