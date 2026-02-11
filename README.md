# DevOps GitOps Repository

This repository manages the deployment of the `k8s-begining` application using **GitOps** principles with ArgoCD and Helm.

## 📂 Repository Structure

k8s-devops/
 ├── README.md               # Project overview and quick start
 ├── SETUP_GUIDE.md          # Setup instructions
 ├── helm/                   # Helm Charts
 │   ├── common/             # Common Helm Chart
 │   ├── k8s-begining/       # Main application Helm Chart
 │   │   ├── values-dev.yml  # Dev values
 │   │   ├── values-qa.yml   # QA values
 │   │   └── values-prod.yml # Prod values
 │   └── ...                 # Other charts
 └── argocd/                 # ArgoCD Application Manifests
     ├── root-app-dev.yml    # Root App for Dev
     ├── root-app-qa.yml     # Root App for QA
     ├── root-app-prod.yml   # Root App for Prod
     ├── root-app-base.yml   # Root App for Base Infra
     └── apps/               # Application defintions
         ├── base/           # Shared Infra (Vault, etc.)
         ├── dev/            # Dev Apps
         ├── qa/             # QA Apps
         └── prod/           # Prod Apps
```

## 🚀 Deployment Workflow

1.  **CI (GitHub Actions)**:
    -   Builds Docker Image.
    -   Updates `helm/k8s-begining/values.yml` with the new tag.
    -   Commits changes to this repo.

2.  **CD (ArgoCD)**:
    -   Detects changes in `helm/k8s-begining` (for `k8s-begining`) or `argocd/application`.
    -   Renders the **Helm Chart**.
    -   Applies manifests to the Kubernetes cluster.

## 📚 Guides

-   [**Setup Guide**](SETUP_GUIDE.md): Instructions for installing K3s, Helm, and ArgoCD.
-   [**Chart Readme**](charts/k8s-begining/README.md): Details about the `k8s-begining` Helm chart.

## 🛠 Quick Actions

### Deploy Environments
You can now manage environments separately using the App of Apps pattern.

```bash
# 1. Deploy Base Infrastructure (Vault, Reloader, External Secrets)
kubectl apply -f argocd/root-app-base.yml

# 2. Deploy Development Environment
kubectl apply -f argocd/root-app-dev.yml

# 3. Deploy QA Environment
kubectl apply -f argocd/root-app-qa.yml

# 4. Deploy Production Environment
kubectl apply -f argocd/root-app-prod.yml
```

Once applied, ArgoCD will automatically sync the applications defined in `argocd/apps/base`, `argocd/apps/dev`, `argocd/apps/qa`, and `argocd/apps/prod` respectively.