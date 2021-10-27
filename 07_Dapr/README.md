## 07_Dapr

Dapr is a distributable application runtime and is intended to be used as building blocks for microservices. It is not specific to Kubernetes, but since running many services is one of the drivers for K8s it is a logical fit. 

An example use case is that you want your services to use a NoSQL database like Cosmos DB. You don't want to implement the code for that integration in every container you run so you outsource it to Dapr (running as a sidecar). Not only that - maybe you decide you want to use MongoDB instead - you change the Dapr configuration, but your code stays the same since it does not integrate directly with the Cosmos SDKs.

There are of course many more things you can do with Dapr. This section currenly only contains the commands required to install Dapr itself. To learn more check out [https://dapr.io](https://dapr.io "dapr.io")

Dapr was created by Microsoft, but is not specific to Azure Kubernetes Service and is aimed at the Kubernetes community at large.