#!/bin/bash
# Create admin user for Vault UI
# Usage: ./create-admin.sh [username] [password]

set -e

NAMESPACE="vault"
POD="vault-0"
USERNAME="${1:-admin}"
PASSWORD="${2:-admin123}"

# Load credentials
if [ -f "vault-keys.txt" ]; then
    source vault-keys.txt
elif [ -z "$ROOT_TOKEN" ]; then
    echo "❌ ROOT_TOKEN not set. Run init.sh first or export ROOT_TOKEN"
    exit 1
fi

echo "🔐 Logging in to Vault..."
kubectl exec -n $NAMESPACE $POD -- vault login $ROOT_TOKEN > /dev/null

echo "👤 Creating admin user..."

# Enable userpass auth
kubectl exec -n $NAMESPACE $POD -- vault auth enable userpass 2>/dev/null || true

# Create admins policy
kubectl exec -n $NAMESPACE $POD -- sh -c 'vault policy write admins - <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF'

# Create admin user
kubectl exec -n $NAMESPACE $POD -- vault write auth/userpass/users/$USERNAME \
    password=$PASSWORD \
    policies=admins

echo ""
echo "✅ Admin user created!"
echo "   Username: $USERNAME"
echo "   Password: $PASSWORD"
echo ""
echo "🌐 Login at: http://<VM_IP>:30200"
