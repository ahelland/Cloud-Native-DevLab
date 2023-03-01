# Based on https://learn.microsoft.com/en-us/azure/container-apps/azure-arc-enable-cluster?tabs=azure-powershell
# Note: depending on the hardware configuration of your cluster you may not have enough CPU and/or memory resources available by default.
# A likely symptom of this is that pods get stuck in a "Pending" state even if the steps below don't produce any errors.
# If your hardware supports it you can add extra nodes to your AKS cluster to fix this. (Use the Set-AksHciNodePool cmdlet for this.)

$clusterName               = "aks01"
$location                  = "westeurope"
$azureRGName               = "AKS"
$extensionName             = "ace-ext"
$namespace                 = "ace-ns" 
$connectedEnvironmentName  = "contoso-ace"
$customLocationName        = "contoso"
$containerAppEnvironmentRG = "rg-ace"

# Install the necessary extensions for Azure CLI
az extension add --name connectedk8s  --upgrade --yes
az extension add --name k8s-extension --upgrade --yes
az extension add --name customlocation --upgrade --yes
az extension add --name containerapp --upgrade --yes

# If you want to deploy with Bicep make sure you have this installed.
az bicep install

# Create separate resource group for the Container Environment
az group create --name $containerAppEnvironmentRG --location $location

# Install Log Analytics
$laWorkspaceName="$containerAppEnvironmentRG-workspace"

az monitor log-analytics workspace create `
  --location $location `
  --resource-group $containerAppEnvironmentRG `
  --workspace-name $laWorkspaceName

$laWorkspaceId=$(az monitor log-analytics workspace show `
    --resource-group $containerAppEnvironmentRG `
    --workspace-name $laWorkspaceName `
    --query customerId `
    --output tsv)

$laWorkspaceIdEnc=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($laWorkspaceId))

$laKey=$(az monitor log-analytics workspace get-shared-keys `
    --resource-group $containerAppEnvironmentRG `
    --workspace-name $laWorkspaceName `
    --query primarySharedKey `
    --output tsv)

$laKeyEnc=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($laKey))

# Install container app extension (with Log Analytics)
az k8s-extension create `
  --resource-group $azureRGName `
  --name $extensionName `
  --cluster-type connectedClusters `
  --cluster-name $clusterName `
  --extension-type 'Microsoft.App.Environment' `
  --release-train stable `
  --auto-upgrade-minor-version true `
  --scope cluster `
  --release-namespace $namespace `
  --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" `
  --configuration-settings "appsNamespace=${namespace}" `
  --configuration-settings "clusterName=${connectedEnvironmentName}" `
  --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${azureRGName}" `
  --configuration-settings "logProcessor.appLogs.destination=log-analytics" `
  --config-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${laWorkspaceIdEnc}" `
  --config-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${laKeyEnc}"

# Get the id of the extension just installed
$extensionId=$(az k8s-extension show `
  --name $extensionName `
  --cluster-type connectedClusters `
  --cluster-name $clusterName `
  --resource-group $azureRGName `
  --query id `
  --output tsv)

# Get the id of the AKS cluster
$connectedClusterId=$(az connectedk8s show `
  --resource-group $azureRGName `
  --name $clusterName `
  --query id `
  --output tsv)

# Create a custom location
az customlocation create `
  --resource-group $azureRGName `
  --name $customLocationName `
  --host-resource-id $connectedClusterId `
  --namespace $namespace `
  --cluster-extension-ids $extensionId

# Verify the custom location has a provisioningState of "Succeeded"
az customlocation show --resource-group $azureRGName --name $customLocationName

# Get the custom location id
$customLocationId=$(az customlocation show `
  --resource-group $azureRGName `
  --name $customLocationName `
  --query id `
  --output tsv)

# From here there are two paths to actually get some apps running in your environment:
# - Using a custom version of the containerapp cli extension
# - Using Bicep

# Custom extension version
# This will not work with the default containerapp extension if that has been installed, 
# so the easiest way is to use the Azure Cloud shell if you don't want to switch between versions. 
# If so remember to copy variables over.
az extension remove --name containerapp
az extension add --source https://download.microsoft.com/download/5/c/2/5c2ec3fc-bd2a-4615-a574-a1b7c8e22f40/containerapp-0.0.1-py2.py3-none-any.whl --yes

# Create Container App environment
az containerapp connected-env create `
  --resource-group $containerAppEnvironmentRG `
  --name $connectedEnvironmentName `
  --custom-location $customLocationId `
  --location $location

# Create App (based on an image from a public registry)
$containerApp="helloworld"
$connectedEnvironmentId=$(az containerapp connected-env list --custom-location $customLocationId -o tsv --query '[].id')

az containerapp create `
    --resource-group $containerAppEnvironmentRG `
    --name $containerApp `
    --environment $connectedEnvironmentId `
    --environment-type connected `
    --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest `
    --target-port 80 `
    --ingress 'external'

# If you're on a server with a desktop experience you can open the app.
# If not copy & paste address to a computer with a browser.
az containerapp browse --resource-group $containerAppEnvironmentRG --name $containerApp

# Bicep version
# .bicep files are in this directory and parameterized (edit them if you like)
# These are the commands to invoke execution of the Bicep code.

# Creating the environment
az deployment sub create --location $location --name ace-on-prem --template-file ace.bicep `
  --parameters location=$location `
  rgName=$containerAppEnvironmentRG `
  customLocationId=$customLocationId `
  connectedEnvironmentName=$connectedEnvironmentName

# Create a container registry for a custom image
# Note: you will get warnings about "possible secrets" - ignore these.
az deployment sub create --location $location --name ace-on-prem --template-file acr.bicep `
  --parameters location=$location `
  rgName=$containerAppEnvironmentRG

# Get name of Azure Container Registry
$acrName=$(az acr list `
  --resource-group $containerAppEnvironmentRG `
  --query '[].name' `
  --output tsv)

# A sample app with a backend and frontend is included in the "TimeGetter" directory.
# This gets the current time and prints it out by having the frontend do an API call to the backend.

# Build & push images to ACR
# TimeBackend
Set-Location .\TimeGetter\TimeBackend
az acr build --registry $acrName  --image timebackend:latest .
cd..
cd..

# TimeFrontend
Set-Location .\TimeGetter\TimeFrontend
az acr build --registry $acrName  --image timefrontend:latest .
cd..
cd..

# Create container apps (will deploy both backend and frontend)
az deployment sub create --location $location --name ace-on-prem --template-file timegetter.bicep `
  --parameters location=$location `
  rgName=$containerAppEnvironmentRG `
  acrName=$acrName `
  connectedEnvironmentName=$connectedEnvironmentName