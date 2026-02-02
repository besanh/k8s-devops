#!/bin/bash
# Install tools locally too
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

echo "=== DEV ==="
kustomize build overlays/dev

echo "=== PROD ==="
kustomize build overlays/prod
