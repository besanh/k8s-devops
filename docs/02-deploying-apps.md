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

## The Auto-Sync Cycle
By default, the applications in this repository use the `automated` sync policy.
This means:
1. You make a change to a chart in `apps/dev/`.
2. You push the commit to GitHub.
3. ArgoCD polls GitHub (every ~3 minutes) and detects the change.
4. ArgoCD automatically applies the changes to your Kubernetes cluster.

## Verification
To check the status of your deployed applications:

```bash
# Check ArgoCD sync status
kubectl get applications -n argocd

# View deployed pods
kubectl get pods -n dev
```
