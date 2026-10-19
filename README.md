# EKS RBAC Least Privilege

Original Kubernetes RBAC examples for separating developer read access from deployment automation.

```bash
kubectl apply -f k8s
kubectl auth can-i list pods -n application --as=system:serviceaccount:application:deployer
```

The `deployer` account is namespace-scoped and cannot access Kubernetes secrets.
Least-privilege Kubernetes RBAC and IAM patterns for EKS.
