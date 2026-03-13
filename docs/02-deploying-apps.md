# Deploying Applications

Once ArgoCD is running, you can orchestrate your application deployments. ArgoCD works on a **Pull model** (GitOps), where it continuously watches this Git repository and applies changes to the cluster.

## Bootstrapping a New App (Manual Apply)
ArgoCD needs to know an application exists before it can track it.
Whenever you create a new application manifest in `argocd/dev/`, you must apply it to the cluster *once* manually:

```bash
# Example: Bootstrapping SeaweedFS
kubectl apply -f argocd/dev/seaweed.yaml

# Example: Bootstrapping a new app remotely without cloning the code on your server
kubectl apply -f https://raw.githubusercontent.com/besanh/k8s-devops/main/argocd/dev/seaweed.yaml
```

Once the application is applied manually the first time, it will appear in the ArgoCD UI.

## The Auto-Sync Cycle (Fully Automated)

This repository uses the **"App of Apps"** pattern. A single **Root Application** (`argocd/root.yaml`) tracks this entire repository and ensures everything in it is applied automatically.

1. You make a change to a chart in `apps/dev/` OR a manifest in `argocd/dev/`.
2. You push the commit to GitHub.
3. ArgoCD detects the change.
4. The **Root Application** or the individual app automatically applies the changes to your cluster.

**Result**: Manual `kubectl apply` is no longer needed for any file inside this repository!

## Verification
To check the status of your deployed applications:

```bash
# Check ArgoCD sync status
kubectl get applications -n argocd

# View deployed pods
kubectl get pods -n dev
```
