# NGINX Lab Helm Chart

## Overview

This Helm chart deploys the NGINX lab application to the local Kubernetes cluster.

It replaces the raw Kubernetes manifests stored under:

```text
kubernetes/apps/nginx-lab/
```

The raw manifests are kept as a reference, while this chart demonstrates Helm-based release management.

## Chart Details

| Field | Value |
|--|--|
| Chart Name | nginx-lab |
| Namespace | devops-lab |
| Default Replicas | 3 |
| Image | nginx:stable |
| Ingress Host | nginx-lab.10.10.10.201.nip.io |
| NodePort Service | 30080 |
| Ingress Controller NodePort | 30081 |

## Lint

```bash
helm lint kubernetes/charts/nginx-lab
```

## Render Templates

```bash
helm template nginx-lab kubernetes/charts/nginx-lab
```

## Install

```bash
helm install nginx-lab kubernetes/charts/nginx-lab
```

## Upgrade

```bash
helm upgrade nginx-lab kubernetes/charts/nginx-lab
```

## Rollback

View release history:

```bash
helm history nginx-lab
```

Roll back to a previous revision:

```bash
helm rollback nginx-lab 1
```

## Verify

```bash
helm list
kubectl get all -n devops-lab
kubectl get ingress -n devops-lab
```

## Access

```bash
curl http://nginx-lab.10.10.10.201.nip.io:30081
```

Or open:

```text
http://nginx-lab.10.10.10.201.nip.io:30081
```

## Uninstall

```bash
helm uninstall nginx-lab
```

If needed, remove the namespace:

```bash
kubectl delete namespace devops-lab
```

## Skills Practiced

- Helm chart structure

- `chart.yaml`

- `values.yaml`

- Helm templates

- Conditional resources

- `helm lint`

- `helm template`

- `helm install`

- `helm upgrade`

- `helm rollback`

- Helm release history
