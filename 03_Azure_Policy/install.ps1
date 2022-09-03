# More info: https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
$clusterName            = "aks01"
$azureRGName            = "AKS"

az k8s-extension create --cluster-type connectedClusters --cluster-name $clusterName --resource-group $azureRGName --extension-type Microsoft.PolicyInsights --name azurepolicy

# To verify things are working
# There should be an azure-policy pod in the kube-system namespace
kubectl get pods -n kube-system

# And a gatekeeper pod in the gatekeeper-system namespace
kubectl get pods -n gatekeeper-system