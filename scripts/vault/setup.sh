#!/bin/bash
# Vault Setup - All-in-one script
# Usage: ./setup.sh [init|unseal|status]

set -e

NAMESPACE="vault"
POD="vault-0"
KEYS_FILE="$(dirname "$0")/vault-keys.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

init() {
    echo "🔐 Initializing Vault..."
    
    # Check if already initialized
    if kubectl exec -n $NAMESPACE $POD -- vault status 2>/dev/null | grep -q "Initialized.*true"; then
        echo -e "${GREEN}✅ Vault already initialized${NC}"
        unseal
        return
    fi
    
    # Initialize
    INIT=$(kubectl exec -n $NAMESPACE $POD -- vault operator init -key-shares=1 -key-threshold=1 -format=json)
    UNSEAL_KEY=$(echo $INIT | jq -r '.unseal_keys_b64[0]')
    ROOT_TOKEN=$(echo $INIT | jq -r '.root_token')
    
    # Save keys
    echo "UNSEAL_KEY=$UNSEAL_KEY" > "$KEYS_FILE"
    echo "ROOT_TOKEN=$ROOT_TOKEN" >> "$KEYS_FILE"
    chmod 600 "$KEYS_FILE"
    
    echo -e "${GREEN}✅ Vault initialized!${NC}"
    echo "   Keys saved to: $KEYS_FILE"
    
    unseal
    setup_environments
    create_admin
}

unseal() {
    if [ ! -f "$KEYS_FILE" ]; then
        echo -e "${RED}❌ No keys file found. Run: ./setup.sh init${NC}"
        exit 1
    fi
    source "$KEYS_FILE"
    
    if kubectl exec -n $NAMESPACE $POD -- vault status 2>/dev/null | grep -q "Sealed.*false"; then
        echo -e "${GREEN}✅ Vault already unsealed${NC}"
        return
    fi
    
    echo "🔓 Unsealing Vault..."
    kubectl exec -n $NAMESPACE $POD -- vault operator unseal $UNSEAL_KEY > /dev/null
    echo -e "${GREEN}✅ Vault unsealed!${NC}"
}

setup_environments() {
    source "$KEYS_FILE"
    kubectl exec -n $NAMESPACE $POD -- vault login $ROOT_TOKEN > /dev/null 2>&1
    
    echo "📁 Setting up environments..."
    
    # Create secret paths
    kubectl exec -n $NAMESPACE $POD -- vault secrets enable -path=secret/dev kv-v2 2>/dev/null || true
    kubectl exec -n $NAMESPACE $POD -- vault secrets enable -path=secret/prod kv-v2 2>/dev/null || true
    
    # Kubernetes auth
    kubectl exec -n $NAMESPACE $POD -- vault auth enable kubernetes 2>/dev/null || true
    kubectl exec -n $NAMESPACE $POD -- sh -c 'vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"' > /dev/null
    
    # Dev role
    kubectl exec -n $NAMESPACE $POD -- vault write auth/kubernetes/role/k8s-begining-dev \
        bound_service_account_names=default \
        bound_service_account_namespaces=k8s-begining-dev \
        policies=default \
        ttl=24h > /dev/null
    
    echo -e "${GREEN}✅ Environments ready: secret/dev, secret/prod${NC}"
}

create_admin() {
    source "$KEYS_FILE"
    kubectl exec -n $NAMESPACE $POD -- vault login $ROOT_TOKEN > /dev/null 2>&1
    
    echo "👤 Creating admin user..."
    kubectl exec -n $NAMESPACE $POD -- vault auth enable userpass 2>/dev/null || true
    kubectl exec -n $NAMESPACE $POD -- vault write auth/userpass/users/admin password=admin123 policies=default > /dev/null
    
    echo -e "${GREEN}✅ Admin user: admin / admin123${NC}"
}

status() {
    echo "📊 Vault Status:"
    kubectl exec -n $NAMESPACE $POD -- vault status 2>/dev/null || echo -e "${RED}Vault not running${NC}"
}

# Main
case "${1:-init}" in
    init)   init ;;
    unseal) unseal ;;
    status) status ;;
    *)      echo "Usage: $0 [init|unseal|status]" ;;
esac

echo ""
echo "🌐 Vault UI: http://172.16.5.133:30200"
