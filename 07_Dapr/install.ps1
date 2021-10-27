# Install the Dapr CLI
powershell -Command "iwr -useb https://raw.githubusercontent.com/dapr/cli/master/install/install.ps1 | iex"

# Verify it installed correctly
dapr

# Install Dapr with mTLS disabled (to play nice with Open Service Mesh)
dapr init -k --enable-mtls=false

# Verify installation
dapr status -k
kubectl get pods --namespace dapr-system

# To uninstall
# dapr uninstall -k