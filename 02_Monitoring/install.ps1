#Install data source and dashboard for Grafana
kubectl apply -f https://raw.githubusercontent.com/microsoft/AKS-HCI-Apps/main/Monitoring/data-source.yaml 
kubectl apply -f https://raw.githubusercontent.com/microsoft/AKS-HCI-Apps/main/Monitoring/dashboards-new.yaml

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts 
helm repo update 
helm install grafana grafana/grafana --version 6.50.7 --set nodeSelector."kubernetes\.io/os"=linux --set sidecar.dashboards.enabled=true --set sidecar.datasources.enabled=true -n monitoring

# Retrieve secret for logging into Grafana (user: admin)
$base64pw = kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" 
$decodepw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64pw))

# Output password for Grafana
"`nGrafana password: " + $decodepw

# Get pod name of Grafana and set up port forwarding
# Access in browser on http://127.0.0.1:3000 (if running on OS with a GUI)
$grafanaPodName = kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}"
kubectl --namespace monitoring port-forward $grafanaPodName 3000
