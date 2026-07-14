# CI/CD Pipeline

## Overview

The lab includes a GitHub Actions workflow that builds a custom NGINX image and pushes it to GitHub Container Registry.

The image is used by the `nginx-lab` Helm chart.

## Application Source

The application source is located at:

```text
app/nginx/
```

Important files:

- `Dockerfile`

- `.dockerignore`

- `index.html`

## Image Build Workflow

Workflow:

```text
.github/workflows/build-nginx-image.yaml
```

The workflow runs on changes to:

```text
app/nginx/**
.github/workflows/build-nginx-image.yaml
```

The workflow:

1.  Checks out the repository

2.  Sets a lowercase GHCR image owner

3.  Uses the short Git SHA as the image tag

4.  Logs in to GitHub Container Registry

5.  Builds the Docker image from app/nginx

6.  Pushes the image to GHCR

7.  Updates the Helm chart values.yaml image repository and tag

8.  Commits the updated image tag back to the repository

## Image Repository

The image is published to:

```text
ghcr.io/stjbizenterp/devops-lab-nginx
```

## Helm Image Values

The Helm chart uses:

```yaml
image:
  repository: ghcr.io/stjbizenterp/devops-lab-nginx
  tag: <short-git-sha>
  pullPolicy: IfNotPresent
  ```

## Deployment Flow

After the GitHub Actions workflow updates the image tag, the latest changes are pulled locally:

```bash
git pull
```

Then the application is upgraded with Helm:

```bash
helm upgrade nginx-lab kubernetes/charts/nginx-lab -n devops-lab
```

Verify rollout:

```bash
kubectl rollout status deployment nginx-lab -n devops-lab
```

Check the deployed image:

```bash
kubectl get deployment nginx-lab -n devops-lab -o jsonpath='{.spec.template.spec.containers[?(@.name=="nginx")].image}'
echo
```

## Validation Workflow

Workflow:

```text
.github/workflows/validate-kubernetes.yaml
```

This workflow validates Kubernetes and Helm resources by running:

- `helm lint`

- `helm template`

- `kubeconform`

## NGINX Configuration

The Docker image owns the application HTML content at:

```text
/usr/share/nginx/html/index.html
```

The Kubernetes ConfigMap provides NGINX configuration at:

```text
/etc/nginx/conf.d/default.conf
```

This config includes the `stub_status` endpoint used by the NGINX Prometheus exporter.

## Design Decision

The Docker image owns the app page content, while Kubernetes manages runtime configuration through a ConfigMap.

This makes CI/CD behavior visible:

```text
Change app/nginx/index.html
→ GitHub Actions builds and pushes a new image
→ Helm values image tag is updated
→ helm upgrade deploys the new image
→ the running page changes
```

## Skills Practiced

- Docker image builds

- GitHub Actions

- GitHub Container Registry

- Immutable image tagging with Git SHA

- Helm-based application deployment

- Kubernetes rollout verification