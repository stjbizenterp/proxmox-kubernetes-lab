# Application Deployment

## Overview

This document describes the deployment of a simple NGINX-based application to the local Kubernetes cluster.

The purpose of this deployment is to practice declarative Kubernetes manifests, namespaces, ConfigMaps, Deployments, Services, NodePort exposure, and basic workload verification.

## Application

| Field | Value |
|---|---|
| Name | nginx-lab |
| Namespace | devops-lab |
| Image | nginx:stable |
| Replicas | 3 |
| Internal Service | nginx-lab |
| External Service | nginx-lab-nodeport |
| NodePort | 30080 |

## Manifest Location

The manifests are stored in:

```text
kubernetes/apps/nginx-lab/
```

## Files
| File | Purpose |
|--|--|
| `namespace.yaml` | Creates the `devops-lab` namespace |
| `configmap.yaml` | Provides a custom NGINX `index.html` page |
| `deployment.yaml` | Creates the NGINX Deployment |
| `service.yaml` | Creates an internal ClusterIP Service |
| `nodeport.yaml` | Exposes the app using NodePort |

## Deployment Command

From the repository root:

```bash
kubectl apply -f kubernetes/apps/nginx-lab/
```

## Verification Commands

```bash
kubectl get all -n devops-lab
kubectl get pods -n devops-lab -o wide
kubectl describe deployment nginx-lab -n devops-lab
kubectl get svc -n devops-lab
```

## Access Test

The application is exposed on NodePort `30080`.

```bash
curl http://10.10.10.201:30080
curl http://10.10.10.202:30080
curl http://10.10.10.203:30080
```

## Expected Result

The response should contain the custom HTML page from the `nginx-lab-html` ConfigMap.

Expected page heading:

`DevOps Lab App`

## Cleanup

`kubectl delete -f kubernetes/apps/nginx-lab/`

## Skills Practiced

- Kubernetes manifests
- Namespace creation
- ConfigMap usage
- Deployment management
- Replica scaling
- Readiness probes
- Liveness probes
- ClusterIP Service
- NodePort Service
- Declarative deployment with Git-tracked YAML
