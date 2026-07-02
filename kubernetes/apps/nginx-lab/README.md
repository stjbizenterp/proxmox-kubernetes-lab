# NGINX Lab Application

## Overview

This directory contains Kubernetes manifests for a simple NGINX-based application deployed to the `devops-lab` namespace.

The application is used to practice Kubernetes workload management, services, ConfigMaps, probes, and NodePort access.

## Files

| File | Purpose |
|---|---|
| `namespace.yaml` | Creates the `devops-lab` namespace |
| `configmap.yaml` | Provides a custom `index.html` page |
| `deployment.yaml` | Deploys three NGINX replicas |
| `service.yaml` | Creates an internal ClusterIP service |
| `nodeport.yaml` | Exposes the app externally on NodePort `30080` |

## Deploy

From the repository root:

```bash
kubectl apply -f kubernetes/apps/nginx-lab/
```

## Verify

```bash
kubectl get all -n devops-lab
kubectl get pods -n devops-lab -o wide
kubectl describe deployment nginx-lab -n devops-lab
```
## Access

The NodePort service exposes the app on port `30080`.

```bash
curl http://10.10.10.201:30080
curl http://10.10.10.202:30080
curl http://10.10.10.203:30080
```

Or open one of the following URLs in a browser:

```bash
http://10.10.10.201:30080
http://10.10.10.202:30080
http://10.10.10.203:30080
```

## Cleanup

```bash
kubectl delete -f kubernetes/apps/nginx-lab/
```
