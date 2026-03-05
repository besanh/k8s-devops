# Setup & Installation Guide

This guide provides step-by-step instructions to set up the infrastructure and deploy the applications using this GitOps repository.

## 1. Prerequisites
- A Kubernetes cluster (K3s recommended).
- `kubectl` installed locally and configured to access the cluster.
- `helm` installed locally.

## 2. Cluster Connectivity (K3s)
Follow these steps to configure `kubectl` to talk to your K3s server:

```bash
# 1. Fetch the kubeconfig from the server
ssh user@<SERVER_IP> "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# 2. Update the server IP (replace 127.0.0.1 with your SERVER_IP)
sed -i '' 's/127.0.0.1/<SERVER_IP>/g' ~/.kube/config

# 3. Verify the connection
kubectl get nodes
```

## 3. Install ArgoCD
If your cluster does not have ArgoCD installed:

```bash
# 1. Create namespace
kubectl create namespace argocd

# 2. Add Helm repo and install
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace argocd

# 3. Access the ArgoCD UI (Initial password)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 4. Deploy Applications (GitOps)
Once ArgoCD is running, you can deploy the applications by applying the manifests in the `argocd/dev/` directory.

### Step 1: Create Namespaces
```bash
kubectl apply -f apps/dev/namespace.yaml
```

### Step 2: Deploy PostgreSQL
```bash
kubectl apply -f argocd/dev/postgres.yaml
```

### Step 3: Deploy k8s-beginning Service
```bash
kubectl apply -f argocd/dev/k8s-beginning.yaml
```

## 5. Verification
After applying the manifests, verify the deployment in the cluster:

```bash
# Check ArgoCD sync status
kubectl get applications -n argocd

# Check pods in the dev and k8s-beginning-dev namespaces
kubectl get pods -n dev
kubectl get pods -n k8s-beginning-dev

# Test access to the health endpoint
curl -i http://<SERVER_IP>:8000/healthz
```

## 🛠 Troubleshooting

### Database Connection Refused
If `k8s-beginning` crashes with `connection refused`:
- Ensure the `postgres` pod is in the `Running` state.
- Verify the `postgres` service exists in the `dev` namespace.

### Password Authentication Failure
If logs show `password authentication failed`:
- Confirm the password in `apps/dev/k8s-beginning/templates/configmap.yaml` matches the one in `apps/dev/postgres/values.yaml`.
- If you changed the password after the database was initialized, you may need to delete the `postgres` pod to force it to re-initialize (since it uses `emptyDir` in this setup).

### ArgoCD Sync Issues
If changes in Git are not reflected in the cluster:
- Force a hard refresh:
  ```bash
  kubectl patch application <APP_NAME> -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
  ```
