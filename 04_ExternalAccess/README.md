## 04_ExternalAccess

This section deals with external access to the cluster. Here defined as being able to reach services by typing a url in the browser (and the like) on a different computer than the host running the cluster. It does not imply "outside your network" unless you have provisioned external IP addresses or opened up a firewall.

This section is complex in the sense that there are many moving parts involved, and you need to provide values that are not preprovided in this repo. It is assumed you:
* Already own and control a domain name.
* That you have created a public Azure DNS Zone before performing these steps.
* That you have delegated said domain to Azure DNS.

There are three components you need to install:
* NGINX Ingress Controller
* ExternalDNS for integration with Azure DNS.
* CertManager for enrolling certificates through Lets Encrypt.

Q: Why nginx? There are a number of other ingress controllers out there.  
A: Yes, there are. We had to start somewhere though, and this is a basic setup that works. Other ingress controllers will be considered later.

Q: Why an Azure public DNS Zone - isn't this primarily a private setup?  
A: Yes, on a concept level we kind of want an internal DNS zone. However, Azure does not support DNS forwarding from on-prem to cloud, and does not support direct lookup outside Azure. So, we need something accessible from the internet even though we put in private IP addresses. (Which works as long as you're on the right network.)

Q: What is I'm not using Azure DNS?  
A: Both ExternalDNS and CertManager supports using other domain name providers, but we're sticking to the Microsoft stack for now. (Look up the docs to make necessary adjustsments.)

Go through the steps in _install.ps1_ and make sure you extract the necessary output values. Put these into the corresponding places in _ExternalDNS.yaml_ and _CertManager.yaml_.

Then install the yaml files:
```  
kubectl apply -f ExternalDNS.yaml
kubectl apply -f CertManager.yaml
```  