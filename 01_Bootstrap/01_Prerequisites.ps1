# We set some variables for where we want files to be.
$drive          = "C:\"
$installPath    = $drive + "Install"
$toolsPath      = $drive + "Tools"
$gitPath        = $toolsPath + "\git"

mkdir $installPath
mkdir $toolsPath
Set-Location $installPath

# Add tools path to Windows Path
# Note if you want it to apply for all users change "User" to "Machine". Machine requires a reboot to persist.
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
[System.Environment]::SetEnvironmentVariable("PATH", $envPath + ";" + $toolsPath, "User")
[System.Environment]::SetEnvironmentVariable("PATH", $envPath + ";" + $toolsPath + "\bin", "User")

# Install Azure Cli
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi

# Download Helm
# https://github.com/helm/helm/releases
Invoke-WebRequest "https://get.helm.sh/helm-v3.6.3-windows-amd64.zip" -OutFile Helm.zip
Expand-Archive -Path Helm.zip -DestinationPath .\
# Helm will extract in a subdirectory; let's bring the executable to the tools directory.
Copy-Item -Path .\windows-amd64\helm.exe $toolsPath

# We will install Git (to clone the rest of the files you need).
# Git requires another addition to the Windows Path
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
[System.Environment]::SetEnvironmentVariable("PATH", $envPath + ";" + $gitPath + "\bin", "User")

# Download and extract the portable version of Git into the tools directory
Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/PortableGit-2.33.0.2-32-bit.7z.exe" -OutFile git.exe
.\git.exe -o $gitPath -y

# The PowerShell prompt needs to be restarted for things to take effect.
exit