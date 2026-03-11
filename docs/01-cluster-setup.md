# Cluster Setup

This guide provides instructions to set up the infrastructure for the GitOps repository.

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

# 3. Access the ArgoCD UI

## Option 1: Port Forwarding (Easiest for local access)
To access the UI securely from your local machine, use `kubectl port-forward`:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
You can then open your browser to: `https://localhost:8080` (Accept the self-signed certificate warning).

## Option 2: NodePort/LoadBalancer
If you want it permanently exposed on your cluster network, you can patch the service to be a LoadBalancer or NodePort instead of ClusterIP.

### Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
