#!/bin/bash
set -e

# Configuration
VAULT_ADDR="http://127.0.0.1:8200"
DB_HOST="postgres.k8s-begining-dev.svc.cluster.local" 
# Use internal service name from inside K8s
DB_PORT="5432"
DB_NAME="anh_k8s_db"
DB_USERNAME="anh_admin" # Existing admin user to manage other users
DB_PASSWORD="anh_admin" # Admin password

# 1. Enable Database Secrets Engine
echo "Enabling database secrets engine at 'database/'..."
vault secrets enable database || echo "Database engine might already be enabled"

# 2. Configure Database Connection
echo "Configuring PostgreSQL connection..."
# Need to use the full connection string so Vault can connect to Postgres
vault write database/config/k8s-begining-postgres \
    plugin_name=postgresql-database-plugin \
    allowed_roles="k8s-begining" \
    connection_url="postgresql://{{username}}:{{password}}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" \
    username="${DB_USERNAME}" \
    password="${DB_PASSWORD}"

# 3. Create a Role
# This role creates a NEW user with a random username/password valid for 1 hour
echo "Creating role 'k8s-begining'..."
vault write database/roles/k8s-begining \
    db_name=k8s-begining-postgres \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON DATABASE \"${DB_NAME}\" TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

# 4. Update Policy
# Allow the k8s-begining role to read dynamic credentials
echo "Updating policy 'k8s-begining'..."
vault policy write k8s-begining - <<EOF
path "database/creds/k8s-begining" {
  capabilities = ["read"]
}
# Keep the old KV path just in case
path "secret/dev/data/k8s-begining/database" {
  capabilities = ["read"]
}
EOF

echo "Dynamic Database Secrets configured!"
echo "New secret path: database/creds/k8s-begining"
