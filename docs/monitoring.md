# Monitoring

## Overview

This document describes the monitoring stack installed in the Kubernetes cluster.

The monitoring stack is based on the `kube-prometheus-stack` Helm chart from the Prometheus Community Helm repository.

It includes:

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter
- Prometheus Operator

## Helm Repository

The Prometheus Community Helm repository was added with:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## Values File

Custom Helm values are stored at:

```text
kubernetes/monitoring/kube-prometheus-stack/values.yaml
```

## Installation

The monitoring stack was installed with:

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f kubernetes/monitoring/kube-prometheus-stack/values.yaml
```

## Namespace

The stack is installed into:

```text
monitoring
```

## Access

Grafana:

```text
http://grafana.10.10.10.201.nip.io:30081
```

Prometheus:

```text
http://prometheus.10.10.10.201.nip.io:30081
```

## Grafana Login

For this local lab:

```text
Username: admin
Password: admin123
```

In a real environment, plaintext credentials should not be committed to Git.

## Verification Commands

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get ingress -n monitoring
helm list -n monitoring
```

## Prometheus Custom Resources

```bash
kubectl get prometheus -n monitoring
kubectl get servicemonitor -n monitoring
kubectl get podmonitor -n monitoring
kubectl get prometheusrule -n monitoring
```

## Useful Prometheus Queries

Check scrape target status:

```promql
up
```

Node CPU:

```promql
rate(node_cpu_seconds_total[5m])
```

Available memory:

```promql
node_memory_MemAvailable_bytes
```

Pod phases:

```promql
kube_pod_status_phase
```

Available deployment replicas:

```promql
kube_deployment_status_replicas_available
```

## Skills Practiced

- Installing monitoring with Helm

- Managing Helm values for third-party charts

- Exposing Grafana with Ingress

- Exposing Prometheus with Ingress

- Inspecting Kubernetes metrics

- Using Prometheus queries

- Using Grafana dashboards

- Understanding Prometheus Operator CRDs
