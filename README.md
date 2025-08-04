# selfhosted-kubernetes-configs
Kubernetes configurations for self-hosted applications


For apps with `kustomization.yaml`, add `env/properties` and/or `env/passwords` as needed for configs and secrets. Set up your Persistent Volumes as you wish and modify the configs accordingly. To start deployment:
```
kubectl apply -k .
```

For others, add the ConfigMaps and Secrets, set up the Persistent Volumes and start deployment:
```
kubectl apply -f .
```

