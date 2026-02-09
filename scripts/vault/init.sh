#!/bin/bash
# Vault Setup Scripts
# Usage: ./init.sh
# Run this ONCE after Vault is deployed to initialize and unseal

set -e

NAMESPACE="vault"
POD="vault-0"

echo "🔐 Initializing Vault..."

# Check if already initialized
STATUS=$(kubectl exec -n $NAMESPACE $POD -- vault status -format=json 2>/dev/null | jq -r '.initialized' || echo "false")

if [ "$STATUS" == "true" ]; then
    echo "⚠️  Vault is already initialized"
    exit 0
fi

# Initialize Vault
INIT_OUTPUT=$(kubectl exec -n $NAMESPACE $POD -- vault operator init -key-shares=1 -key-threshold=1 -format=json)

UNSEAL_KEY=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[0]')
ROOT_TOKEN=$(echo $INIT_OUTPUT | jq -r '.root_token')

# Save credentials
echo "📝 Saving credentials to vault-keys.txt (KEEP THIS SECURE!)"
echo "UNSEAL_KEY=$UNSEAL_KEY" > vault-keys.txt
echo "ROOT_TOKEN=$ROOT_TOKEN" >> vault-keys.txt
chmod 600 vault-keys.txt

# Unseal Vault
echo "🔓 Unsealing Vault..."
kubectl exec -n $NAMESPACE $POD -- vault operator unseal $UNSEAL_KEY

echo "✅ Vault initialized and unsealed!"
echo ""
echo "🔑 Credentials saved to: vault-keys.txt"
echo "   UNSEAL_KEY: $UNSEAL_KEY"
echo "   ROOT_TOKEN: $ROOT_TOKEN"
