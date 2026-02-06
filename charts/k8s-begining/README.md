helm/k8s-begining/
 ├─ Chart.yaml        → chart identity
 ├─ values.yaml       → defaults
 └─ templates/
     ├─ deployment.yaml → pods
     ├─ service.yaml    → networking
     ├─ configmap.yaml  → config files
     ├─ secret.yaml     → secrets
     ├─ ingress.yaml    → external HTTP
     └─ _helpers.tpl    → naming
