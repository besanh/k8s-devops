# Complete Setup & Deployment Guide

Based on our session, here is the complete list of commands to replicate your setup: connecting to K3s, installing ArgoCD, and deploying your application with data services.


## 1. Connect to K3s Cluster

First, configure `kubectl` on your local machine to talk to your K3s VM.

```bash
# SSH into VM to get kubeconfig (requires root/sudo access)
ssh user@localhost "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# Update server IP in the config file
sed -i '' 's/127.0.0.1/localhost/g' ~/.kube/config

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


## 3. Deploy Data Services (Postgres & Redis)

We deployed these directly to K8s using manifests.

```bash
# 1. Create manifests (if they don't exist)
# (See environments/dev/postgres.yml and redis.yml in your repo)

# 2. Apply manifests manually (or let ArgoCD handle it if committed)
kubectl apply -f environments/dev/postgres.yml
kubectl apply -f environments/dev/redis.yml

# 3. Verify Data Pods
kubectl get pods -n k8s-begining-dev
```


## 4. Deploy Application via ArgoCD

This connects ArgoCD to your Git repository to manage the app.

```bash
# 1. Apply the Application Manifest
kubectl apply -f argocd/applications/k8s-begining.yml

# 2. Sync the Application (if auto-sync is off or to force update)
argocd app sync k8s-begining-dev

# OR using kubectl to trigger hard refresh
kubectl patch application k8s-begining-dev -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# 3. Verify Project Resources
kubectl get ns k8s-begining-dev
kubectl get all -n k8s-begining-dev
```


## 5. Troubleshooting Commands

Commands we used to fix issues:

```bash
# Fix DNS on VM (if images fail to pull)
ssh user@localhost "echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf"

# Restart App Deployment
kubectl rollout restart deployment/k8s-begining -n k8s-begining-dev

# Check Logs
kubectl logs -l app=k8s-begining -n k8s-begining-dev
kubectl logs -l app=postgres -n k8s-begining-dev

# Access App via LoadBalancer (VM IP)
curl http://localhost:8000/helloworld/user
```