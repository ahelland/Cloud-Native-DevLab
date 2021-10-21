## HelloFoo

HelloFoo is a very simple test app. It consists of a backend and a frontend container both written in .NET Core. It mainly serves to illustrate how to get a web app with an API running, but works nicely for that specific purpose.

The code for this app can be found here:  
[https://github.com/ahelland/HelloFoo](https://github.com/ahelland/HelloFoo)

There are actually two ways to install it and two things you get to test.

### GitOps with Flux
For development purposes installing on the command line is fine, but at scale this does not work. A more recommended approach is by using a GitOps methodology and the built-in mechanism for this in our lab is Flux. (Flux is not a Microsoft product and also works outside AKS.) It is of course useful for testing in a dev lab as well.

The basic idea is that you commit your code, the CI process creates new images, updates the yaml, etc. before an agent installed in the cluster notices and pulls in the updates automatically. (Simplified explanation of course.)

The build process can inject environment variables and the like, but this being a public repo such things are not included here.

To use and test this run the following commands:  
```  
# Add the HelloFoo external public repo
az k8s-configuration create --name hellofoo --cluster-name aks01 --resource-group AKS --operator-instance-name flux --operator-namespace hellofoo --operator-params='--git-readonly --git-path=k8s' --repository-url https://github.com/ahelland/HelloFoo --scope namespace --cluster-type connectedClusters

# Get the IP address of the frontend
kubectl get svc -n hellofoo
```  
You should then be able to open the site in your web browser by accessing the IP address you got.

More info:  
[https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-gitops-ci-cd](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-gitops-ci-cd)  
[https://fluxcd.io/](https://fluxcd.io/)

### Install with kubectl
Since the command above points to a public repo with generic settings it only exposes the service on an IP address. If you want to customize things further you can apply the yaml manifest (from this repo) like this:

```  
kubectl apply -f hellofoo.yaml
```  

Note that you should edit the file first to specify your domain name.