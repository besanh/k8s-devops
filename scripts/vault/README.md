# Vault Setup Scripts

Scripts for managing HashiCorp Vault in Kubernetes.

## Quick Start

```bash
cd scripts/vault

# 1. Initialize Vault (run ONCE)
./init.sh

# 2. Setup dev/prod environments
./setup-environments.sh

# 3. Create admin user for UI
./create-admin.sh admin admin123

# 4. Load secrets for each environment
./load-secrets.sh dev k8s-begining
./load-secrets.sh prod k8s-begining
```

## Scripts

| Script | Description |
|--------|-------------|
| `init.sh` | Initialize and unseal Vault (first time only) |
| `unseal.sh` | Unseal Vault after pod/VM restart |
| `setup-environments.sh` | Create dev/prod secret paths and policies |
| `create-admin.sh` | Create admin user for Vault UI |
| `load-secrets.sh` | Load secrets from env files to Vault |

## Secrets Files

Edit files in `secrets/` folder:
- `secrets/dev.env` - Development environment secrets
- `secrets/prod.env` - Production environment secrets

## After VM Restart

```bash
# 1. Fix ArgoCD
systemctl restart k3s && sleep 30 && kubectl delete pods -n argocd --all

# 2. Unseal Vault
cd scripts/vault
./unseal.sh
```

## Access Vault UI

- URL: `http://<VM_IP>:30200`
- Login: admin / admin123
