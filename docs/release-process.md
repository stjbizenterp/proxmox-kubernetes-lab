# Release Process

## Overview

This document describes the lightweight release process for the Proxmox Kubernetes DevOps lab.

The current process uses GitHub Actions to build container images and update Helm chart image tags automatically, while deployment to the Kubernetes cluster is still performed manually with Helm.

This provides a controlled release workflow without giving GitHub Actions direct access to the local Kubernetes cluster.

## Current Release Flow

1. Update application source files under:

```text
app/nginx/
```

2. Commit and push changes to main.

3. GitHub Actions runs the image build workflow:

```text
.github/workflows/build-nginx-image.yaml
```

4. The workflow builds a new image and pushes it to GitHub Container Registry.

5. The workflow tags the image with the short Git commit SHA.

6. The workflow updates the Helm chart image tag in:

```text
kubernetes/charts/nginx-lab/values.yaml
```

7. The workflow commits the updated Helm values file back to main.

8. Pull the updated desired state locally:

```bash
git pull
```

9. Validate the Helm chart:

```bash
helm lint kubernetes/charts/nginx-lab
helm template nginx-lab kubernetes/charts/nginx-lab
```

10. Deploy the release:

```bash
helm upgrade nginx-lab kubernetes/charts/nginx-lab
```

11. Verify rollout:

```bash
kubectl rollout status deployment nginx-lab -n devops-lab
```

12. Verify the running image:

```bash
kubectl get deployment nginx-lab -n devops-lab \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

13. Verify application access:

```bash
curl http://nginx-lab.10.10.10.201.nip.io:30081
```

## Why Deployment Is Still Manual

The Kubernetes cluster runs locally on Proxmox and is not directly accessible from GitHub Actions.

Keeping deployment manual for now has benefits:

- Avoids exposing the cluster API publicly

- Keeps release control explicit

- Preserves a clear separation between CI and deployment

- Makes each release step visible for learning purposes

## Image Tagging Strategy

The workflow uses short Git SHA image tags instead of latest.

Example:

```yaml
image:
  repository: ghcr.io/stjbizenterp/devops-lab-nginx
  tag: abc1234
  pullPolicy: IfNotPresent
```

This improves:

- Traceability

- Repeatability

- Rollback clarity

- Auditability

## Rollback

View Helm release history:

```bash
helm history nginx-lab
```

Rollback to a previous release:

```bash
helm rollback nginx-lab REVISION_NUMBER
```

Verify rollback:

```bash
kubectl rollout status deployment nginx-lab -n devops-lab
kubectl get deployment nginx-lab -n devops-lab \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
curl http://nginx-lab.10.10.10.201.nip.io:30081
```

## Future Improvements

Potential future improvements include:

- Using pull requests for automated image tag updates

- Adding release tags

- Adding changelog generation

- Adding Argo CD or Flux for GitOps-based deployment

- Adding automated deployment from a self-hosted runner inside the homelab network
