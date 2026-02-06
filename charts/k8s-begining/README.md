# k8s-begining Helm Chart

A Helm chart for deploying the `k8s-begining` application on Kubernetes.

## File Structure

```
helm/k8s-begining/
 ├─ Chart.yaml        → Chart metadata (version, dependencies)
 ├─ values.yaml       → Default configuration values
 └─ templates/
     ├─ deployment.yaml → Main application Pods
     ├─ service.yaml    → Internal networking (ClusterIP)
     ├─ configmap.yaml  → Application configuration (mounted as volume)
     ├─ secret.yaml     → Application secrets (optional)
     ├─ ingress.yaml    → External access (Ingress/Traefik)
     └─ _helpers.tpl    → Template helpers
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Docker image repo | `anhle3532/k8s-begining` |
| `image.tag` | Docker image tag | `latest` |
| `service.port` | HTTP Port | `8000` |
| `config.enabled` | Enable ConfigMap generation | `true` |
| `secret` | Map of secrets (optional) | `{}` |

## Usage

Override values in your environment (e.g., `environments/dev/values.yaml`).
