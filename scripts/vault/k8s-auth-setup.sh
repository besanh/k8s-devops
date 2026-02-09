#!/bin/bash
# Vault Kubernetes Authentication Setup
# Usage: ./k8s-auth-setup.sh
# Run this AFTER Vault is initialized and unsealed

set -e

VAULT_NAMESPACE="vault"
APP_NAMESPACE="k8s-begining-dev"
APP_ROLE="k8s-begining"

echo "🔐 Setting up Vault Kubernetes Authentication..."

# Check if we can access Vault
kubectl exec -n $VAULT_NAMESPACE vault-0 -- vault status > /dev/null 2>&1 || {
    echo "❌ Vault is not accessible or sealed. Run './setup.sh unseal' first."
    exit 1
}

echo "1️⃣ Enabling Kubernetes auth method..."
kubectl exec -n $VAULT_NAMESPACE vault-0 -- vault auth enable kubernetes 2>/dev/null || echo "   (already enabled)"

echo "2️⃣ Configuring Kubernetes auth..."
kubectl exec -n $VAULT_NAMESPACE vault-0 -- vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc"

echo "3️⃣ Enabling KV secrets engine..."
kubectl exec -n $VAULT_NAMESPACE vault-0 -- vault secrets enable -path=secret kv-v2 2>/dev/null || echo "   (already enabled)"

echo "4️⃣ Creating database secrets..."
kubectl exec -n $VAULT_NAMESPACE vault-0 -- vault kv put secret/k8s-begining/database \
    username="anh_admin" \
    password="anh_admin" \
    host="postgres" \
    port="5432" \
    dbname="anh_k8s_db"

echo "5️⃣ Creating policy for k8s-begining..."
kubectl exec -n $VAULT_NAMESPACE vault-0 -- sh -c 'vault policy write k8s-begining - <<EOF
path "secret/data/k8s-begining/*" {
  capabilities = ["read"]
}
EOF'

echo "6️⃣ Creating Kubernetes auth role..."
kubectl exec -n $VAULT_NAMESPACE vault-0 -- vault write auth/kubernetes/role/$APP_ROLE \
    bound_service_account_names=default \
    bound_service_account_namespaces=$APP_NAMESPACE \
    policies=$APP_ROLE \
    ttl=1h

echo ""
echo "✅ Vault Kubernetes auth setup complete!"
echo ""
echo "📋 Summary:"
echo "   - Secrets path: secret/k8s-begining/database"
echo "   - Role: $APP_ROLE"
echo "   - Bound namespace: $APP_NAMESPACE"
echo ""
echo "🚀 Next: Deploy your app and Vault Agent will inject secrets automatically."
