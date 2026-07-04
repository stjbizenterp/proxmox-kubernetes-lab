# Helm

## Overview

This document describes the conversion of the NGINX lab application from raw Kubernetes YAML manifests to a Helm chart.

The goal was to practice Kubernetes application packaging, templating, configurable values, release upgrades, and rollbacks.

## Chart Location

```text
kubernetes/charts/nginx-lab/
```

## Original Manifest Location

```text
kubernetes/apps/nginx-lab/
```

The original raw manifests are retained for reference.

## Chart Structure

```text
kubernetes/charts/nginx-lab/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── nodeport.yaml
│   └── ingress.yaml
└── README.md
```

## Chart Metadata

```yaml
apiVersion: v2
name: nginx-lab
description: A Helm chart for deploying the NGINX lab application to Kubernetes
type: application
version: 0.1.0
appVersion: "1.0.0"
```

## Linting

The chart was linted with:

```bash
helm lint kubernetes/charts/nginx-lab
```

## Rendering Templates

The chart was rendered locally before installation:

```bash
helm template nginx-lab kubernetes/charts/nginx-lab
```

This allowed inspection of generated Kubernetes YAML before applying anything to the cluster.

## Installing the Release

The chart was installed with:

```bash
helm install nginx-lab kubernetes/charts/nginx-lab
```

## Verifying the Release

```bash
helm list
kubectl get all -n devops-lab
kubectl get ingress -n devops-lab
```

## Upgrade Practice

The release was upgraded by changing values in `values.yaml`, then running:

```bash
helm upgrade nginx-lab kubernetes/charts/nginx-lab
```

Example changes:

- Changed replica count

- Changed page heading

## Rollback Practice

Release history was checked with:

```bash
helm history nginx-lab
```

The release was rolled back with:

```bash
helm rollback nginx-lab 1
```

## Access

The Helm-managed app is available through the existing ingress controller:

```text
http://nginx-lab.10.10.10.201.nip.io:30081
```

## Skills Practiced

- Helm chart creation

- Helm values

- Helm templates

- Conditional resources

- Rendering manifests locally

- Installing Helm releases

- Upgrading Helm releases

- Rolling back Helm releases

- Comparing raw manifests with templated manifests
