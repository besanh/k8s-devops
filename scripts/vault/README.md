# Vault Setup

Only `setup.sh` is needed - **everything else is done via the Vault UI**.

## Quick Start

```bash
# One-time init (after deploying Vault)
./setup.sh init

# After VM restart (unseal Vault)
./setup.sh unseal
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
