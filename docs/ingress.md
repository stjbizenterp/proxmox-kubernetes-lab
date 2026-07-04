# Kubernetes Ingress

## Overview

This document describes the setup of NGINX Ingress Controller in the local Kubernetes cluster.

The purpose of this step was to expose applications using hostname-based routing instead of accessing each application directly through individual NodePort services.

## Ingress Controller

Installed NGINX Ingress Controller using the official bare-metal deployment manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/baremetal/deploy.yaml
```

## Namespace

The ingress controller was installed into:

```text
ingress-nginx
```

## Verification

Checked ingress controller pods:

```bash
kubectl get pods -n ingress-nginx
```

Checked ingress controller service:

```bash
kubectl get svc -n ingress-nginx
```

## NodePort Configuration

Because this cluster is running on local VMs instead of a cloud provider with a managed load balancer, the ingress controller service uses `NodePort`.

The HTTP NodePort was patched to a predictable value:

```bash
kubectl patch svc ingress-nginx-controller \
  -n ingress-nginx \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/ports/0/nodePort","value":30081}]'
```

## Application Ingress

The nginx-lab application uses this ingress host:

```text
nginx-lab.10.10.10.201.nip.io
```

The Ingress manifest is stored at:

```text
kubernetes/apps/nginx-lab/ingress.yaml
```

## Access

Because the ingress controller is exposed on NodePort `30081`, the app can be accessed at:

```text
http://nginx-lab.10.10.10.201.nip.io:30081
```

Or tested with an explicit Host header:

```bash
curl -H "Host: nginx-lab.10.10.10.201.nip.io" http://10.10.10.201:30081
```

## Skills Practiced

- Ingress controller installation

- Bare-metal Kubernetes service exposure

- NodePort-based ingress access

- Hostname-based routing

- Kubernetes Ingress resources

- `kubectl describe ingress`

- Service-to-ingress routing
