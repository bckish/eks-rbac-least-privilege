#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { echo 'Usage: bash scripts/check.sh LOCAL_KIND_KUBECONFIG' >&2; exit 2; }
cfg=$1
context=$(kubectl --kubeconfig "$cfg" config current-context)
server=$(kubectl --kubeconfig "$cfg" config view --minify -o jsonpath='{.clusters[0].cluster.server}')
[[ $context == kind-* && $server == https://127.0.0.1:* ]] || { echo 'Use disposable local Kind only' >&2; exit 2; }
k(){ kubectl --kubeconfig "$cfg" "$@"; }
subject=system:serviceaccount:policy-lab:deployer
k -n policy-lab auth can-i list pods --as="$subject" | grep -Fx yes
k -n policy-lab auth can-i patch deployments/demo-api --subresource=scale --as="$subject" | grep -Fx yes
for action in 'get secrets' 'create pods' 'patch deployments/demo-api' 'patch deployments/other-api --subresource=scale'; do
  if k -n policy-lab auth can-i $action --as="$subject"; then echo "Unexpected approval: $action" >&2; exit 1; fi
done
if k -n default auth can-i list pods --as="$subject"; then echo 'Unexpected cross-namespace access' >&2; exit 1; fi
echo 'PASS: namespace read and named scale allowed; direct secret, pod creation, template mutation and cross-namespace access denied'
k apply --dry-run=server -f "$(dirname "$0")/../fixtures/compliant-pod.yaml"
if k -n policy-lab run policy-admission-check --image=busybox:1.36 --restart=Never --dry-run=server; then
  echo 'Unexpected admission of noncompliant pod' >&2; exit 1
fi
echo 'PASS: restricted pod admission accepts compliant and rejects noncompliant spec (server dry-run only)'
