# More info: https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes

# Adapt variables to your liking. Defaults provided.
$tenantId       = "xxxx-xxx-xxx-xxx-xxxx"
$subscriptionId = "xxxx-xxx-xxx-xxx-xxxx"
$azureRGName    = "AKS"
$clusterName    = "aks01"

$scope="/subscriptions/" + $subscriptionId + "/resourceGroups/" + $azureRGName + "/providers/Microsoft.Kubernetes/connectedClusters/" + $clusterName

## Create a service principal for Azure Policy
$sp = New-AzADServicePrincipal -DisplayName "AzStackHCI-AKS01_AzurePolicy" -Role "Policy Insights Data Writer (Preview)" -Scope $scope
@{ appId=$sp.ApplicationId;password=[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret));tenant=(Get-AzContext).Tenant.Id } | ConvertTo-Json

# Note: You cannot retrieve the secret later, so if you need that please copy it to a file.

# Install Azure Policy
helm repo add azure-policy https://raw.githubusercontent.com/Azure/azure-policy/master/extensions/policy-addon-kubernetes/helm-charts
helm repo update

$clientId=$sp.ApplicationId
$clientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret))

helm install azure-policy-addon azure-policy/azure-policy-addon-arc-clusters --set azurepolicy.env.resourceid=$scope --set azurepolicy.env.clientid=$clientId --set azurepolicy.env.clientsecret=$clientSecret --set azurepolicy.env.tenantid=$tenantId

# To verify things are working
# There should be an azure-policy pod in the kube-system namespace
kubectl get pods -n kube-system

# And a gatekeeper pod in the gatekeeper-system namespace
kubectl get pods -n gatekeeper-system