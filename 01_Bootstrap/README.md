## 01_Bootstrap

### Prereqs before the prereqs scripts
You need to have a Windows Server installed (Server 2022 or Azure Stack HCI) with the Hyper-V role installed. You also need a virtual switch configured in Hyper-V connected to a working LAN.

### Usage
This section installs the basic tools you need to create the cluster. Run through the files in numeric sequence.

The scrips are:
```  
01_Prerequisites.ps1 - Downloads  
02_PS-Modules.ps1    - Installing PowerShell Modules  
03_AKS_Install.ps1   - The actual AKS install  
```

Scripts are intended to run in a PowerShell cmd prompt, or in the PowerShell ISE.

You will notice a number of "exits" in the files preventing you from running everything in one unattended batch. This is unfortunately the way it works when installing the basics since the command line doesn't update dynamically, and you just need to pick up where you left off.

For the bootstrap you might want to just copy & paste from GitHub, but Git is installed along the way and this repo is subsequently cloned. This way you can work the rest of the magic from your file system directly if you like.

Note: if you do the copy & paste approach I have seen weird issues where sometimes the "-" character is left out when copying to a VM session. Make sure that all parameters are tagged as such when you see unexpected errors.