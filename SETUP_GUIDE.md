# Setup & Installation Guide

This guide covers the initial setup of the infrastructure: K3s, Helm, and ArgoCD.

## 1. Connect to K3s Cluster

First, configure `kubectl` on your local machine to talk to your K3s VM.

```bash
# SSH into VM to get kubeconfig (requires root/sudo access)
ssh user@<VM_IP> "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# Update server IP in the config file
sed -i '' 's/127.0.0.1/<VM_IP>/g' ~/.kube/config

# Verify connection
kubectl get nodes
```

## 2. Install Helm & ArgoCD

If setting up from scratch:

```bash
# 1. Install Helm (if not installed locally)
brew install helm

# 2. Add ArgoCD Helm Chart
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 3. Install ArgoCD
kubectl create namespace argocd
helm install argocd argo/argo-cd --namespace argocd --version 5.51.6

# 4. Verify ArgoCD Pods
kubectl get pods -n argocd -w
```

## 3. ArgoCD Initial Login

```bash
# Get Admin Password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Port Forward UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access at https://localhost:8080
```

## 4. Troubleshooting

### ArgoCD Not Working After VM Restart

If ArgoCD is not accessible after restarting the VM, run this command on the VM:

```bash
sudo systemctl restart k3s && sleep 60 && kubectl delete pods -n argocd --all
```

Then verify:
```bash
kubectl get pods -n argocd
curl -k https://<VM_IP>:8080/
```
