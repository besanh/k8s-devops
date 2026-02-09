#!/bin/bash
# Setup Vault secret paths for dev and prod
# Usage: ./setup-environments.sh
# Requires: ROOT_TOKEN from init.sh

set -e

NAMESPACE="vault"
POD="vault-0"

# Load credentials
if [ -f "vault-keys.txt" ]; then
    source vault-keys.txt
elif [ -z "$ROOT_TOKEN" ]; then
    echo "❌ ROOT_TOKEN not set. Run init.sh first or export ROOT_TOKEN"
    exit 1
fi

echo "🔐 Logging in to Vault..."
kubectl exec -n $NAMESPACE $POD -- vault login $ROOT_TOKEN > /dev/null

echo "📁 Creating secret paths..."

# Enable KV-v2 for dev
kubectl exec -n $NAMESPACE $POD -- vault secrets enable -path=secret/dev kv-v2 2>/dev/null && \
    echo "✅ Created secret/dev" || echo "⚠️  secret/dev already exists"

# Enable KV-v2 for prod
kubectl exec -n $NAMESPACE $POD -- vault secrets enable -path=secret/prod kv-v2 2>/dev/null && \
    echo "✅ Created secret/prod" || echo "⚠️  secret/prod already exists"

echo "📋 Creating policies..."

# Dev policy (full access)
kubectl exec -n $NAMESPACE $POD -- sh -c 'vault policy write dev-policy - <<EOF
path "secret/dev/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/data/dev/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF'
echo "✅ Created dev-policy"

# Prod policy (read-only)
kubectl exec -n $NAMESPACE $POD -- sh -c 'vault policy write prod-policy - <<EOF
path "secret/prod/*" {
  capabilities = ["read", "list"]
}
path "secret/data/prod/*" {
  capabilities = ["read", "list"]
}
EOF'
echo "✅ Created prod-policy"

echo "🔑 Enabling Kubernetes auth..."
kubectl exec -n $NAMESPACE $POD -- vault auth enable kubernetes 2>/dev/null && \
    echo "✅ Enabled kubernetes auth" || echo "⚠️  kubernetes auth already enabled"

kubectl exec -n $NAMESPACE $POD -- sh -c 'vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"'

# Dev role
kubectl exec -n $NAMESPACE $POD -- vault write auth/kubernetes/role/k8s-begining-dev \
    bound_service_account_names=default \
    bound_service_account_namespaces=k8s-begining-dev \
    policies=dev-policy \
    ttl=24h
echo "✅ Created k8s-begining-dev role"

# Prod role
kubectl exec -n $NAMESPACE $POD -- vault write auth/kubernetes/role/k8s-begining-prod \
    bound_service_account_names=default \
    bound_service_account_namespaces=k8s-begining-prod \
    policies=prod-policy \
    ttl=24h
echo "✅ Created k8s-begining-prod role"

echo ""
echo "✅ Environment setup complete!"
echo "   - secret/dev  → k8s-begining-dev namespace"
echo "   - secret/prod → k8s-begining-prod namespace"
