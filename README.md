# Proxmox Kubernetes DevOps Lab

![Validate Kubernetes Manifests and Helm Chart](https://github.com/stjbizenterp/proxmox-kubernetes-lab/actions/workflows/validate-kubernetes.yaml/badge.svg)

## Overview

This repository documents my local DevOps lab built with Proxmox, Ubuntu, Kubernetes, Terraform, Ansible, CI/CD, and observability tooling.

The purpose of this lab is to rebuild and demonstrate hands-on DevOps skills, including infrastructure provisioning, Kubernetes administration, automation, CI/CD, monitoring, and troubleshooting.

This lab uses immutable Git SHA-based container image tags for Kubernetes deployments instead of relying on the mutable `latest` tag.

## Current Lab Architecture

| VM ID | Hostname | Role | vCPU | RAM | Disk | IP |
|---|---|---|---:|---:|---:|---|
| 201 | k8s-cp-01 | Kubernetes control plane | 2 | 4 GB | 32 GB | DHCP |
| 202 | k8s-worker-01 | Kubernetes worker | 2 | 4 GB | 32 GB | DHCP |
| 203 | k8s-worker-02 | Kubernetes worker | 2 | 4 GB | 32 GB | DHCP |

## Tools Used

- Proxmox VE
- Ubuntu Server 24.04 LTS
- Cloud-init
- QEMU Guest Agent
- Kubernetes
- GitHub
- Terraform
- Ansible
- GitHub Actions
- Prometheus
- Grafana

## Progress

- [x] Created GitHub repository
- [x] Created initial repository structure
- [x] Created Ubuntu 24.04 cloud-init template
- [x] Cloned Kubernetes VMs
- [x] Configured static IP addresses for Kubernetes nodes
- [x] Installed container runtime
- [x] Installed Kubernetes components
- [x] Initialized Kubernetes control plane
- [x] Joined worker nodes
- [x] Installed Flannel CNI
- [x] Verified cluster node readiness
- [x] Deployed test application imperatively with `kubectl`
- [x] Created declarative Kubernetes manifests for lab application
- [x] Deployed NGINX lab application from manifests
- [x] Added ConfigMap-backed custom HTML page
- [x] Added ClusterIP service
- [x] Added NodePort service
- [x] Practiced scaling deployment up and down
- [x] Practiced troubleshooting `ImagePullBackOff`
- [x] Added NGINX Ingress Controller
- [x] Added application Ingress resource
- [x] Verified hostname-based ingress routing
- [x] Documented cluster setup, application deployment, ingress, and troubleshooting
- [x] Converted application manifests to a Helm chart
- [x] Added Helm values for configurable deployments
- [x] Practiced Helm upgrade and rollback
- [x] Added GitHub Actions validation workflow
- [x] Added Helm linting to CI
- [x] Added Helm template rendering to CI
- [x] Added Kubernetes manifest schema validation to CI
- [x] Tightened kubeconform validation by removing ignored missing schemas
- [x] Practiced intentional CI failure and recovery
- [x] Built custom NGINX container image
- [x] Published image to GitHub Container Registry
- [x] Updated Helm chart to use custom image
- [x] Disabled ConfigMap HTML override for image-based app content
- [x] Deployed custom image to Kubernetes
- [x] Replaced mutable `latest` deployment tag with immutable image tag
- [x] Updated Helm image pull policy for immutable tag usage
- [x] Verified deployment image and running pod image digest
- [x] Automated Helm image tag updates after container builds
- [x] Added GitHub Actions bot commits for image tag changes
- [x] Documented lightweight release process
- [x] Installed kube-prometheus-stack with Helm
- [x] Deployed Prometheus, Grafana, Alertmanager, kube-state-metrics, and node-exporter
- [x] Exposed Grafana through Ingress
- [x] Exposed Prometheus through Ingress
- [x] Verified Kubernetes metrics in Prometheus
- [x] Explored Grafana dashboards
- [x] Added NGINX Prometheus exporter sidecar
- [x] Exposed application metrics on port `9113`
- [x] Added ServiceMonitor for application scraping
- [x] Verified app metrics in Prometheus
- [x] Created basic Grafana panels for app metrics

## Current Lab Capabilities

- Provisioned a three-node Kubernetes cluster on Proxmox
- Deployed an NGINX application using Helm
- Exposed the application with NodePort and Ingress
- Added an NGINX Prometheus exporter sidecar
- Configured Prometheus scraping with a ServiceMonitor
- Built Grafana panels for NGINX request and connection metrics
- Added PrometheusRule alerts for app availability and request rate
- Validated alert firing and recovery through Prometheus and Alertmanager

## Documentation

- [Proxmox Ubuntu Cloud-Init Template](docs/proxmox-template.md)
- [Kubernetes Cluster Setup](docs/kubernetes-cluster.md)
- [Troubleshooting Notes](docs/troubleshooting.md)
- [Application Deployment](docs/app-deployment.md)
- [Kubernetes Ingress](docs/ingress.md)
- [Helm](docs/helm.md)
- [GitHub Actions](docs/github-actions.md)
- [Custom Container Image](docs/custom-image.md)
- [Immutable Image Tags](docs/immutable-image-tags.md)
- [Release Process](docs/release-process.md)
- [Monitoring](docs/monitoring.md)
- [Application Monitoring](docs/app-monitoring.md)
- [Kubernetes Cluster Build](docs/kubernetes-cluster.md)
- [Application Deployment](docs/app-deployment.md)
- [Application Monitoring](docs/app-monitoring.md)
- [Application Alerting](docs/app-alerting.md)
- [Troubleshooting Notes](docs/troubleshooting.md)