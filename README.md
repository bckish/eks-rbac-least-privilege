# Kubernetes Least-Privilege and Zero-Trust Foundation

Independent local policy lab for a namespace-scoped service account. The account can read workload metadata and scale only the named `demo-api` deployment. It cannot create pods, patch deployment templates, read Secrets, scale unrelated deployments or read pods in another namespace. No cloud IAM or EKS access is provisioned.

The namespace enforces Kubernetes Restricted Pod Security, and NetworkPolicy manifests declare deny-by-default ingress and egress with an explicit frontend-to-API TCP path. DNS and other dependencies intentionally require their own documented allowances.

## Run on a disposable local cluster

```bash
kind create cluster --name policy-lab --image kindest/node:v1.34.3 --kubeconfig ./policy-lab.kubeconfig
kubectl --kubeconfig ./policy-lab.kubeconfig apply -k k8s
bash scripts/check.sh ./policy-lab.kubeconfig
kind delete cluster --name policy-lab --kubeconfig ./policy-lab.kubeconfig
```

Verified 26 November 2026: real `kubectl auth can-i` checks granted only expected namespace and named scaling permissions; all five denial checks passed. Server dry-run accepted a compliant pod and refused a noncompliant pod under Restricted admission. All three NetworkPolicy resources were admitted. Network traffic enforcement was **not** tested on a policy-capable CNI; do not equate policy resource admission with network isolation. Production Calico and IAM integration remain follow-up tasks.
