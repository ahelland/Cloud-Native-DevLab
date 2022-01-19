# Re-use existing variables or uncomment below (and correct values accordingly)
#$azureRGName = "AKS"
#$clusterName = "aks01"

# Enable silent install of az extensions
az config set extension.use_dynamic_install=yes_without_prompt

# Provision a "hellofoo" app into a new namespace
az k8s-configuration flux create -g $azureRGName -c $clusterName -n hellofoo --namespace hellofoo -t connectedClusters --scope cluster -u https://github.com/ahelland/hellofoo --branch master --kustomization name=01 path=./k8s

# To acquire IP address of load balancer for the frontend app
kubectl get svc hellofoo-frontend -n hellofoo