#!/bin/bash
# Vault Setup
# Usage: ./setup.sh [init|unseal]

case "$1" in
  init)
    echo "🔐 Initializing Vault..."
    kubectl exec -n vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1
    echo ""
    echo "⚠️  SAVE THE KEYS ABOVE! You need the Unseal Key after every restart."
    ;;
  unseal)
    read -p "Enter unseal key: " KEY
    kubectl exec -n vault vault-0 -- vault operator unseal "$KEY"
    ;;
  status)
    kubectl exec -n vault vault-0 -- vault status
    ;;
  *)
    echo "Usage: $0 [init|unseal|status]"
    ;;
esac
