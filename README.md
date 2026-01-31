# Deploy to dev environment
kubectl apply -k services/k8s-service/overlay/dev

# Delete dev environment
kubectl delete -k services/k8s-service/overlay/dev

# Deploy to prod environment
kubectl apply -k services/k8s-service/overlay/prod

# Delete prod environment
kubectl delete -k services/k8s-service/overlay/prod