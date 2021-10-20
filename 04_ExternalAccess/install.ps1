# Installs the necessary components for external access to the cluster.
# Adapt variables to your liking. Defaults provided.
$subscriptionId = "xxxx-xxx-xxx-xxx-xxxx"
$azureDNSRGName = "rg-dns"
$domainName     = "contoso.com"

$scope="/subscriptions/" + $subscriptionId + "/resourceGroups/" + $azureDNSRGName + "/providers/Microsoft.Network/dnszones/" + $domainName

## Create a service principal for DNS integration
$sp = New-AzADServicePrincipal -DisplayName "AzStackHCI-AKS01_DNS" -Role "DNS Zone Contributor" -Scope $scope

# Do some conversion magic to wrap the details inside json and output as a Base64-encoded string
# Note: You cannot retrieve the secret later, so if you need that please copy it to a file.
$json = @{tenantId=(Get-AzContext).Tenant.Id; subscriptionId=$subscriptionId; resourceGroup=$azureDNSRGName; aadClientId=$sp.ApplicationId;aadClientSecret=[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)) } | ConvertTo-Json
$byteArray = [System.Text.Encoding]::UTF8.GetBytes($json)
$base64 = [System.Convert]::ToBase64String($byteArray)

# For use in ExternalDNS.yaml
"`nazure.json: " + $base64

$rawSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret))
$byteArraySecret = [System.Text.Encoding]::UTF8.GetBytes($rawSecret)
$base64Secret = [System.Convert]::ToBase64String($byteArraySecret)

# For use in CertManager.yaml
"`n For use in certmanager.yaml"
"`nclientID :" + $sp.ApplicationId
"`nclient-secret: " +  $base64Secret

# Create a namespace for Nginx and CertManager
kubectl create namespace ingress-basic

# Installing NGINX
# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic cert-manager.io/disable-validation=true

# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-basic --set controller.replicaCount=2 --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux   

# Installing CertManager
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager --namespace ingress-basic --set installCRDs=true --set nodeSelector."kubernetes\.io/os"=linux --set webhook.nodeSelector."kubernetes\.io/os"=linux --set cainjector.nodeSelector."kubernetes\.io/os"=linux