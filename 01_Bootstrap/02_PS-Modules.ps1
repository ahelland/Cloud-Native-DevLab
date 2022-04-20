# We need a newer version of PowerShellGet
# If problems check this link: https://www.thomasmaurer.ch/2019/02/update-powershellget-and-packagemanagement/
Install-Module –Name PowerShellGet –Force
Update-Module -Name PowerShellGet

# The PowerShell prompt needs to be restarted for things to take effect.
exit

# https://docs.microsoft.com/en-us/azure-stack/aks-hci/kubernetes-walkthrough-powershell

# Trust PSGallery to avoid confirmation prompts
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

# This installs the module for AKS HCI (preceded by its dependencies)
Install-Module -Name Az.Accounts -Repository PSGallery -RequiredVersion 2.2.4 -AcceptLicense
Install-Module -Name Az.Resources -Repository PSGallery -RequiredVersion 3.2.0 -AcceptLicense
Install-Module -Name AzureAD -Repository PSGallery -RequiredVersion 2.0.2.128 -AcceptLicense
Install-Module -Name AksHci -Repository PSGallery -AcceptLicense

# Modules need to be imported explicitly
Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module AzureAD
Import-Module AksHci

# Install and enable posh-git for PowerShell
Install-Module posh-git
Import-Module posh-git
Add-PoshGitToProfile -AllHosts​​​​​​​

# Set up a directory for repos and clone this one
$drive          = "C:\"
$repoPath       = $drive + "Repos"

mkdir $repoPath
Set-Location $repoPath

git clone https://github.com/ahelland/Cloud-Native-DevLab.git

# Close all PowerShell windows and reopen a new administrative session to check if you have the latest version of the PowerShell module.
exit

# Current version is 1.1.30 (April 2022 Release)
Get-Command -Module AksHci

# Log in to Azure 
# (DeviceAuth switch used when on server for doing the actual login on a desktop. Can be omitted if you perform auth directly on server.)
Connect-AzAccount -UseDeviceAuthentication

# Verify from the output that the right subscription is selected
# In case it's not list the subs you can access
Get-AzSubscription

# If you need to set a specific subscription
# Set-AzContext -Subscription "xxxx-xxxx-xxxx-xxxx"

# Validate you have the necessary resource providers registered
Get-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Get-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration

# If you don't have the RPs registered run the commands below
# Register-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
# Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration

#To make sure modules get loaded properly restart Powershell
exit