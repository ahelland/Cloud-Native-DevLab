## 03_Azure_Policy

This section enables Azure Policy for your cluster to audit and deny according to policies you define. You can find more on the built-in policies supported by Azure here:  
[https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/policy-reference](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/policy-reference)

You can also create custom policies for your AKS cluster based on the rego policy language:  
[https://www.openpolicyagent.org/docs/latest/policy-language/](https://www.openpolicyagent.org/docs/latest/policy-language/)

The intention of enabling Azure Policy in your dev lab is that when moving your workload to production you might hit snags where your deployment is rejected because it doesn't meet certain security standards. This way you can simulate such situtations in your dev environment, and attempt to sort it out preemptively.

Follow the instructions here to set up the "Kubernetes cluster pod security baseline standards for Linux-based workloads" initiative:  
[https://docs.microsoft.com/en-us/azure/aks/use-azure-policy](https://docs.microsoft.com/en-us/azure/aks/use-azure-policy)

Necessary yamls for testing are already in this repo.

```  
### Test a privileged pod (should be rejected)
kubectl apply -f nginx-privileged.yaml

### Test an unprivileged pod (should go through)
kubectl apply -f nginx-unprivileged.yaml
```  