# Troubleshooting

## Database Connection Refused
If `k8s-beginning` crashes with `connection refused`:
- Ensure the `postgres` pod is in the `Running` state.
- Verify the `postgres` service exists in the `dev` namespace.

## Password Authentication Failure
If logs show `password authentication failed`:
- Confirm the password in `apps/dev/k8s-beginning/templates/configmap.yaml` matches the one in `apps/dev/postgres/values.yaml`.
- If you changed the password after the database was initialized, you may need to delete the `postgres` pod to force it to re-initialize (since it uses `emptyDir` in this setup).

## ArgoCD UI Access Issues
If you cannot access the ArgoCD UI on the VM:
- Restart K3s and clear the ArgoCD pods to force a clean startup:
  ```bash
  systemctl restart k3s && sleep 30 && kubectl delete pods -n argocd --all
  ```
