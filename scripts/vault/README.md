# Vault Setup

Only `setup.sh` is needed - **everything else is done via the Vault UI**.

## Quick Start

```bash
# One-time init (after deploying Vault)
./setup.sh init

# After VM restart (unseal Vault)
./setup.sh unseal

# Set up Kubernetes auth for app secret injection
./k8s-auth-setup.sh
```

## Vault UI

Access: `http://172.16.5.133:30200`

**Everything below is done in the UI:**

| Task | UI Location |
|------|-------------|
| Create secrets | Secrets Engines → Enable → KV |
| Add secrets | Navigate to path → Create secret |
| Create users | Access → Auth Methods → userpass |
| Create policies | Policies → Create ACL policy |

## Kubernetes Auth Setup

The `k8s-auth-setup.sh` script automates:
1. Enabling Kubernetes auth method
2. Storing database credentials at `secret/k8s-begining/database`
3. Creating policy for the app
4. Creating Kubernetes auth role

