## 05_MonitoringIngress

This section provides the YAML files for applying ingress to the monitoring tools in the _02_Monitoring_ section. (Meaning you can access Jaeger from jaeger.contoso.com instead of 192.168.0.123.)

You need to perform the steps in the section _04_ExternalAccess_ before going through this section. You should also perform the steps in _install.ps1_ from _02_Monitoring_. The files in this section should work whether you ran the YAML files in _02_Monitoring_ or not.

You need to replace the placeholder domain name (contoso.com) with your own domain name in the YAML files.

### Note: There are apparently some snags with running Grafana behind an ingress in this setup, so currently there is no config for that purpose.