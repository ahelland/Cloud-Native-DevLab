## 02_Monitoring

To install Grafana and enable Jaeger run _install.ps1_

If you want to expose the monitoring services through a load balancer apply the corresponding yaml files. This sets up the services as accessible outside the cluster in the ip range you specified during install. This does not require any DNS integration or such, but is not a solution if you want to access through a DNS name like prometheus.contoso.com.

If you want to expose the services with a DNS name skip the application of the yaml files. (You still need to run _install.ps1_ for things to work.)

```
kubectl create -f 01_Prometheus.yaml
kubectl create -f 02_Grafana.yaml
kubectl create -f 03_Jaeger.yaml
```

To display the IP addresses to be used for browsing:
```
kubectl get svc -A
```