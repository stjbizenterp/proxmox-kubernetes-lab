# GitHub Actions

## Overview

This document describes the GitHub Actions workflow used to validate Kubernetes and Helm configuration in this repository.

The goal of this workflow is to practice CI validation for Kubernetes resources before changes are merged or deployed.

## Workflow Location

```text
.github/workflows/validate-kubernetes.yaml
```

## Workflow Triggers

The workflow runs on:

- Pushes to the main branch

- Pull requests targeting the main branch

- Manual runs through workflow_dispatch

## Validation Steps

The workflow performs the following steps:

- Checks out the repository

- Installs Helm

- Installs kubeconform

- Runs helm lint

- Renders the Helm chart with helm template

- Validates the rendered manifests with kubeconform

## Helm Lint

The Helm chart is linted with:

```bash
helm lint kubernetes/charts/nginx-lab
```

This checks the chart for common structure, syntax, and metadata issues.

## Helm Template Rendering

The Helm chart is rendered into plain Kubernetes YAML:

```bash
helm template nginx-lab kubernetes/charts/nginx-lab > rendered/nginx-lab.yaml
```

Rendering the chart helps catch template errors before deployment.

## Kubernetes Schema Validation

The rendered manifests are validated with kubeconform:

```bash
kubeconform \
  -strict \
  -summary \
  rendered/nginx-lab.yaml
```

The workflow intentionally does not use `-ignore-missing-schemas` because this lab currently uses standard Kubernetes resources. This allows CI to fail when a resource uses an invalid or unsupported `apiVersion`.

## Automated Image Tag Updates

The custom NGINX image build workflow updates the Helm chart image tag automatically after a successful image build.

Workflow location:

```text
.github/workflows/build-nginx-image.yaml
```

When files under app/nginx/ are changed on the main branch, the workflow:

1. Builds a custom NGINX container image

2. Pushes the image to GitHub Container Registry

3. Tags the image with the short Git commit SHA

4. Updates the Helm chart image tag in values.yaml

5. Commits the updated values.yaml back to main

The updated Helm values file contains:

```yaml
image:
  repository: ghcr.io/stjbizenterp/devops-lab-nginx
  tag: SHORT_GIT_SHA
  pullPolicy: IfNotPresent
```

This keeps Git as the desired state source for the currently deployable application image.

## Skills Practiced

- GitHub Actions workflow creation

- CI validation

- Helm chart linting

- Helm template rendering

- Kubernetes manifest schema validation

- Pull request and push-based validation workflows
