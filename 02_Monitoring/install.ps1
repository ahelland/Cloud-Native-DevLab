#Install data source and dashboard for Grafana
kubectl apply -f https://raw.githubusercontent.com/microsoft/AKS-HCI-Apps/main/Monitoring/data-source.yaml 
kubectl apply -f https://raw.githubusercontent.com/microsoft/AKS-HCI-Apps/main/Monitoring/dashboards.yaml

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts 
helm repo update 
helm install grafana grafana/grafana --version 6.11.0 --set nodeSelector."kubernetes\.io/os"=linux --set sidecar.dashboards.enabled=true --set sidecar.datasources.enabled=true -n monitoring

# Retrieve secret for logging into Grafana (user: admin)
$base64pw = kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" 
$decodepw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64pw))

# Enable Jaeger support in OSM config
$jsonpatch = '{"spec":{"observability":{"tracing":{"enable":true,"address": "jaeger.jaeger.svc.cluster.local","port":9411,"endpoint":"/api/v2/spans"}}}}' | ConvertTo-Json 
kubectl patch meshconfig osm-mesh-config -n arc-osm-system -p $jsonpatch --type=merge

# Output password for Grafana
"`nGrafana password: " + $decodepw