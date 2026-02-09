#!/bin/bash
# Unseal Vault after pod restart
# Usage: ./unseal.sh
# Run after VM/pod restart

set -e

NAMESPACE="vault"
POD="vault-0"

# Load credentials
if [ -f "vault-keys.txt" ]; then
    source vault-keys.txt
elif [ -z "$UNSEAL_KEY" ]; then
    echo "❌ UNSEAL_KEY not set. Check vault-keys.txt or export UNSEAL_KEY"
    exit 1
fi

echo "🔓 Unsealing Vault..."
kubectl exec -n $NAMESPACE $POD -- vault operator unseal $UNSEAL_KEY

echo "✅ Vault unsealed!"
kubectl exec -n $NAMESPACE $POD -- vault status
