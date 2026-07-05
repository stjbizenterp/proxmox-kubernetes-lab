# Custom Container Image

## Overview

This document describes building and deploying a custom NGINX container image for the Kubernetes lab application.

The purpose of this milestone was to move from a stock upstream image to a custom image built from source files stored in this repository.

## App Source Location

```text
app/nginx/
```

## Files

```text
app/nginx/
├── Dockerfile
├── index.html
└── .dockerignore
```

## Dockerfile

```dockerfile
FROM nginx:stable-alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
```

## GitHub Actions Workflow

The image build workflow is located at:

```text
.github/workflows/build-nginx-image.yaml
```

The workflow builds and pushes the image to GitHub Container Registry.

## Image Registry

The image is published to:

```text
ghcr.io/stjbizenterp/devops-lab-nginx
```

## Tags

The workflow publishes:

- ` latest`

- Git commit SHA tag

## Helm Integration

The Helm chart was updated to use the custom image:

```yaml
image:
  repository: ghcr.io/stjbizenterp/devops-lab-nginx
  tag: latest
  pullPolicy: Always
```

The ConfigMap-backed HTML mount was disabled so the page is served from inside the custom image:

```yaml
configMapHtml:
  enabled: false
```

## Deployment

The image was deployed with:

```bash
helm upgrade nginx-lab kubernetes/charts/nginx-lab
```

## Verification

```bash
kubectl rollout status deployment nginx-lab -n devops-lab
kubectl get pods -n devops-lab -o wide
curl http://nginx-lab.10.10.10.201.nip.io:30081
```

Expected heading:

```text
DevOps Lab App - Custom Container Image
```

## Skills Practiced

- Writing a Dockerfile

- Building a custom container image

- Using GitHub Container Registry

- GitHub Actions image build workflow

- Docker image tagging

- Helm chart image configuration

- Deploying a custom image to Kubernetes
