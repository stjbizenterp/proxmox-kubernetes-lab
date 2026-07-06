# Immutable Image Tags

## Overview

This document describes the transition from using the mutable `latest` container image tag to using an immutable Git SHA-based image tag.

The purpose of this step was to improve deployment traceability and make it clear which application image version is running in Kubernetes.

## Previous Configuration

The Helm chart initially used:

```yaml
image:
  repository: ghcr.io/YOUR_GITHUB_USERNAME/devops-lab-nginx
  tag: latest
  pullPolicy: Always
```

This works for testing but is not ideal because latest can point to different images over time.

## Updated Configuration

The chart was updated to use a Git SHA-based image tag:

```yaml
image:
  repository: ghcr.io/stjbizenterp/devops-lab-nginx
  tag: bb05a03
  pullPolicy: IfNotPresent
```

## Why Immutable Tags Are Better

Using immutable tags improves:

- Traceability

- Rollback safety

- Deployment repeatability

- Auditability

- Debugging clarity

A running Kubernetes deployment can now be traced back to a specific image tag and Git commit.

## GitHub Actions Image Tags

The image build workflow publishes both:

- ` latest`

- A Git SHA-based tag

The SHA tag is used for Kubernetes deployment.

## Validation

The rendered Helm chart was checked with:

```bash
helm template nginx-lab kubernetes/charts/nginx-lab | grep "image:"
```

The live Kubernetes deployment image was checked with:

```bash
kubectl get deployment nginx-lab -n devops-lab \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The running pod image and digest were checked with:

```bash
kubectl get pod nginx-lab-77f97c696d-xxqpr -n devops-lab \
  -o jsonpath='{.status.containerStatuses[0].image}{"\n"}{.status.containerStatuses[0].imageID}{"\n"}'
```

## Automated Updates

Image tags are updated automatically by GitHub Actions.

When the custom NGINX app source changes, the workflow builds a new image, pushes it to GitHub Container Registry, and commits the new Git SHA-based tag into the Helm chart values file.

This keeps deployments traceable while avoiding manual image tag updates.

## Skills Practiced

- Understanding mutable vs immutable tags

- Using Git SHA-based image tags

- Updating Helm image values

- Validating rendered Helm output

- Verifying Kubernetes deployment images

- Inspecting pod image digests
