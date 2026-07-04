# Proxmox Kubernetes DevOps Lab

## Overview

This repository documents my local DevOps lab built with Proxmox, Ubuntu, Kubernetes, Terraform, Ansible, CI/CD, and observability tooling.

The purpose of this lab is to rebuild and demonstrate hands-on DevOps skills, including infrastructure provisioning, Kubernetes administration, automation, CI/CD, monitoring, and troubleshooting.

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
- [x] Created Ubuntu 24.04 cloud-init template
- [x] Cloned Kubernetes VMs
- [x] Configured static IP addresses
- [x] Installed containerd
- [x] Installed `kubeadm`, `kubelet`, and `kubectl`
- [x] Initialized Kubernetes control plane
- [x] Joined worker nodes
- [x] Installed Flannel CNI
- [x] Deployed NGINX lab application from manifests
- [x] Added ConfigMap, Deployment, ClusterIP Service, and NodePort Service
- [x] Practiced scaling and troubleshooting
- [x] Added NGINX Ingress Controller
- [x] Added hostname-based Ingress routing
- [x] Documented lab setup and troubleshooting notes
- [ ] Convert application to Helm chart
- [ ] Add GitHub Actions validation
- [ ] Build and deploy custom container image
- [ ] Add CI/CD deployment workflow
- [ ] Add monitoring with Prometheus and Grafana
- [ ] Add centralized logging
- [ ] Automate infrastructure/configuration with Terraform and Ansible

## Documentation

- [Proxmox Ubuntu Cloud-Init Template](docs/proxmox-template.md)
- [Kubernetes Cluster Setup](docs/kubernetes-cluster.md)
- [Troubleshooting Notes](docs/troubleshooting.md)
- [Application Deployment](docs/app-deployment.md)
- [Kubernetes Ingress](docs/ingress.md)