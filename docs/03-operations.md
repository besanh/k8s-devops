# Operations & Commands

This document contains relevant commands to operate, apply, sync, and roll back applications via `kubectl` and `argocd`.

## Applying Changes

Usually, you should just `git push` to your repository and wait for ArgoCD to sync.
If you need to force an immediate action:

### Force ArgoCD to check for updates immediately (Hard Refresh)
```bash
# Using kubectl
kubectl annotate app <APP_NAME> -n argocd argocd.argoproj.io/refresh=hard --overwrite

# Example
kubectl annotate app seaweed-dev -n argocd argocd.argoproj.io/refresh=hard --overwrite
```

### Manual Sync (If auto-sync is disabled or failing)
```bash
argocd app sync <APP_NAME>
```

## Rollbacks

With GitOps, the primary way to rollback is to **revert the commit in Git**. ArgoCD will instantly detect that the `main` branch has reverted and will sync the cluster back to the old state.

If you absolutely must perform an immediate, manual rollback on the cluster side before fixing Git:

**Using the ArgoCD CLI:**
```bash
# List deployment history
argocd app history <APP_NAME>

# Rollback to a specific ID (where ID is from the history command)
argocd app rollback <APP_NAME> <ID>
```

*(Note: If auto-sync is on, ArgoCD will try to sync back to the broken Git state unless you fix Git or pause auto-sync!)*

## Restarting / Bouncing Deployments
If you just need to restart pods without changing configuration:

```bash
# Rollout restart a deployment
kubectl rollout restart deployment <DEPLOYMENT_NAME> -n <NAMESPACE>

# Rollout restart a statefulset
kubectl rollout restart statefulset <STATEFULSET_NAME> -n <NAMESPACE>
```

## Local Development & Validation (Helm)

Before pushing your changes to Git, you should always validate your Helm charts locally to catch syntax errors or misconfigurations.

### Linting a chart
Check for syntax and structural errors:
```bash
helm lint apps/dev/<CHART_NAME>
# Example: helm lint apps/dev/seaweed
```

### Rendering templates
Preview exactly what YAML Kubernetes will receive after the Go templates and `values.yaml` are processed (dry-run):
```bash
helm template <RELEASE_NAME> apps/dev/<CHART_NAME>
# Example: helm template seaweed apps/dev/seaweed
```

## Managing ArgoCD via CLI (`argocd`)

If you prefer using the terminal over the ArgoCD UI, you can use the `argocd` CLI tool.

### Get the initial admin password
When ArgoCD is first installed, it generates a random password for the `admin` user. You can retrieve it from the cluster secret:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### Login to ArgoCD
```bash
argocd login <ARGOCD_SERVER> --insecure
```

### List all applications
```bash
argocd app list
```

### View application status and health
```bash
argocd app get <APP_NAME>
```

### Delete an application
If you need to completely nuke an application and all its managed resources:
```bash
argocd app delete <APP_NAME>
```

## Viewing SeaweedFS Files (Web UI)

SeaweedFS comes with a built-in web interface where you can view the cluster status, topology, and **browse uploaded files**. 

To view files specifically, you need to access the **Filer** component, which handles the file and directory structures (similar to a normal file explorer).

Because SeaweedFS is deployed as a `LoadBalancer` service, you can access it directly using your Kubernetes node (VM) IP address! 

Simply point your web browser to:
`http://<SERVER_IP>:8888`

This will provide a native directory explorer UI where you can click through folders, see the files you've uploaded, and even upload or download files directly through the browser!
