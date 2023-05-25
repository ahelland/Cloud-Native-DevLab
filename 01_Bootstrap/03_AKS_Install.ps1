# Adapt variables to your liking. Defaults provided.
# Network settings are just placeholders and will most likely need to be adjusted.
$k8sVersion             = "v1.25.7"
$clusterName            = "aks01"
$vnetName               = "aksvnet"
$vnetSwitch             = "LAN"
$macPool                = "aksMacPool"
$nodeIpPoolStart        = "192.168.1.101"
$nodeIpPoolEnd          = "192.168.1.110"
$vipPoolStart           = "192.168.1.111"
$vipPoolEnd             = "192.168.1.120"
$ipAddressPrefix        = "192.168.1.0/24"
$gateway                = "192.168.1.1"
$dnsServers             = "192.168.1.1"
$cloudServiceCidr       = "192.168.1.100/24"
$azureSubscriptionId    = "xxxx-xxx-xxx-xxx-xxxx"
$azureRGName            = "AKS"

# Note: when reinstalling to preserve config add the SkipConfigCleanup parameter
# Uninstall-AksHci -SkipConfigCleanup -Verbose

### aks01 ###
$vnet = New-AksHciNetworkSetting -name $vnetName -vSwitchName $vnetSwitch -macPoolName $macPool -k8sNodeIpPoolStart $nodeIpPoolStart -k8sNodeIpPoolEnd $nodeIpPoolEnd -vipPoolStart $vipPoolStart -vipPoolEnd $vipPoolEnd -ipAddressPrefix $ipAddressPrefix -gateway $gateway -dnsServers $dnsServers
Set-AksHciConfig -vnet $vnet -imageDir C:\ClusterStorage\Volume01\Images -workingDir C:\ClusterStorage\Volume01\WorkDir -cloudConfigLocation C:\ClusterStorage\Volume01\Config -workingDir C:\ClusterStorage\Volume01\ImageStore  -cloudservicecidr $cloudServiceCidr
Set-AksHciRegistration -subscriptionId $azureSubscriptionId -resourceGroupName $azureRGName

# Install management cluster
Install-AksHci -Verbose

# Install workload cluster
# If you're not starved on RAM (64 GB +) you can create the cluster without parameters
New-AksHciCluster -Name $clusterName -kubernetesVersion $k8sVersion

# For 32 GB you might want to tweak the sizes of the VMs involved and adapt the cmdlet as illustrated below
# VmSizes https://docs.microsoft.com/en-us/azure-stack/aks-hci/reference/ps/get-akshcivmsize
# New-AksHciCluster -name $clusterName -nodePoolName nodepool-01 -nodeCount 1 -nodeVmSize "Standard_A4_v2" -osType linux -loadBalancerVmSize "Standard_A2_v2" -controlplaneVmSize "Standard_A2_v2" -kubernetesVersion $k8sVersion -Verbose

# Enable an Arc connecion to Azure (no cost)
Enable-AksHciArcConnection -name $clusterName

# Verify you can get info about the cluster
Get-AksHciCluster -name $clusterName

# Retrieve credentials to be used with kubectl
Get-AksHciCredential -name $clusterName -Confirm:$false

# Enable Prometheus for monitoring
Install-AksHciMonitoring -Name $clusterName -storageSizeGB 100 -retentionTimeHours 240

# Enable silent install of az extensions
az config set extension.use_dynamic_install=yes_without_prompt

# Install Azure Defender for AKS (note that this has a cost of roughly 2$ pr month pr core)
az k8s-extension create --name microsoft.azuredefender.kubernetes --cluster-type connectedClusters --cluster-name $clusterName --resource-group $azureRGName --extension-type microsoft.azuredefender.kubernetes

# Install the Azure Key Vault Secrets Provider extension
# Note: extra steps to integrate with the actual vault
# https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-akv-secrets-provider#provide-identity-to-access-azure-key-vault
az k8s-extension create --cluster-name $clusterName --resource-group $azureRGName --cluster-type connectedClusters --extension-type Microsoft.AzureKeyVaultSecretsProvider --name akvsecretsprovider