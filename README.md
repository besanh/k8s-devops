# DevOps GitOps Repository

This repository manages the deployment of the `k8s-begining` application using **GitOps** principles with ArgoCD and Helm.

## 📂 Repository Structure

```
k8s-devops/
 ├── README.md               # Project overview and quick start
 ├── SETUP_GUIDE.md          # Setup instructions
 ├── helm/                   # Helm Charts
 │   ├── common/             # Common Helm Chart (shared templates)
 │   ├── k8s-begining/       # Main application Helm Chart
 │   ├── external-secrets/   # External Secrets Operator Helm Chart
 │   ├── reloader/           # Reloader Helm Chart
 │   └── vault/              # Vault Helm Chart
 └── argocd/                 # ArgoCD Application Manifests
     └── application/        # ArgoCD application definitions
         ├── k8s-begining.yml
         ├── external-secrets.yml
         ├── reloader.yml
         └── vault.yml
```

## 🚀 Deployment Workflow

1.  **CI (GitHub Actions)**:
    -   Builds Docker Image.
    -   Updates `environments/dev/values.yaml` with the new tag (`dev-latest` or specific SHA).
    -   Commits changes to this repo.

2.  **CD (ArgoCD)**:
    -   Detects changes in `environments/dev`.
    -   Renders the **Helm Chart**.
    -   Applies manifests to the Kubernetes cluster.

## 📚 Guides

-   [**Setup Guide**](SETUP_GUIDE.md): Instructions for installing K3s, Helm, and ArgoCD.
-   [**Chart Readme**](charts/k8s-begining/README.md): Details about the `k8s-begining` Helm chart.

## 🛠 Quick Actions

### Deploy Application
The application + Postgres + Redis are all managed by the Helm Chart in `environments/dev`.

```bash
# Apply ArgoCD Application
kubectl apply -f argocd/applications/k8s-begining.yml
```

### Refresh Application
```bash
argocd app get k8s-begining-dev --refresh
```