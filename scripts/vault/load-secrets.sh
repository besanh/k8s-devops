#!/bin/bash
# Load secrets from env file into Vault
# Usage: ./load-secrets.sh <dev|prod> [app-name]

set -e

ENV="${1:-dev}"
APP="${2:-k8s-begining}"
NAMESPACE="vault"
POD="vault-0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate environment
if [[ ! "$ENV" =~ ^(dev|prod)$ ]]; then
    echo "❌ Invalid environment: $ENV (use dev or prod)"
    exit 1
fi

ENV_FILE="$SCRIPT_DIR/secrets/${ENV}.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Secrets file not found: $ENV_FILE"
    exit 1
fi

# Load credentials
if [ -f "$SCRIPT_DIR/vault-keys.txt" ]; then
    source "$SCRIPT_DIR/vault-keys.txt"
elif [ -z "$ROOT_TOKEN" ]; then
    echo "❌ ROOT_TOKEN not set. Run init.sh first or export ROOT_TOKEN"
    exit 1
fi

echo "🔐 Logging in to Vault..."
kubectl exec -n $NAMESPACE $POD -- vault login $ROOT_TOKEN > /dev/null

echo "📝 Loading secrets from $ENV_FILE..."

# Read env file and build vault kv put command
VAULT_CMD="vault kv put secret/${ENV}/${APP}"
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    # Remove quotes from value
    value="${value%\"}"
    value="${value#\"}"
    VAULT_CMD="$VAULT_CMD ${key}=\"${value}\""
done < "$ENV_FILE"

# Execute vault command
kubectl exec -n $NAMESPACE $POD -- sh -c "$VAULT_CMD"

echo ""
echo "✅ Secrets loaded to: secret/${ENV}/${APP}"
echo ""
echo "Verify with:"
echo "  kubectl exec -n vault vault-0 -- vault kv get secret/${ENV}/${APP}"
