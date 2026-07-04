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
  -ignore-missing-schemas \
  rendered/nginx-lab.yaml
```

## Skills Practiced

- GitHub Actions workflow creation

- CI validation

- Helm chart linting

- Helm template rendering

- Kubernetes manifest schema validation

- Pull request and push-based validation workflows
