## 06_Azure_Service_Operator

This section introduces Azure Service Operator as a component you might find handy using in your AKS cluster.

While you deploy the components you code to Kubernetes it's not unlikely you may want to use other third-party components as well - this could be a SQL Server, a messaging service, or something else. You can create these separately from your app deployment, and outside your homelab you may need to get someone else to do it.

The point of Azure Service Operator is to bring the Azure resource lifecycle closer to your developer inner loop. Instead of going to the Azure Portal or running PowerShell/Azure CLI to create components in the cloud you define a YAML manifest just like any other Kubernetes resource to have it handled for you.

More info can be found on Microsoft's GitHub repo:  
[https://github.com/Azure/azure-service-operator](https://github.com/Azure/azure-service-operator)

Note: At the moment there are no samples in this section it is mainly a pointer to things you can look into. While still in Alpha you should consider v2 instead of v1.