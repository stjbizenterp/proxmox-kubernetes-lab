# Proxmox Kubernetes DevOps Lab Walkthrough

## Overview

This project is a self-hosted DevOps homelab built on Proxmox VE. The goal of the lab is to demonstrate a complete infrastructure-to-application workflow using modern DevOps tools and practices.

The lab provisions virtual machines with Terraform, configures them with Ansible, bootstraps a Kubernetes cluster with kubeadm, deploys an application with Helm, builds and publishes a custom container image through GitHub Actions, and monitors the application with Prometheus and Grafana.

## Architecture

The active environment uses three Terraform-managed Ubuntu 24.04 virtual machines running on Proxmox VE.

| Role | Hostname | VM ID | IP Address |
|---|---|---|---|
| Control plane | `k8s-tf-cp-01` | 301 | `10.10.10.211` |
| Worker | `k8s-tf-worker-01` | 302 | `10.10.10.212` |
| Worker | `k8s-tf-worker-02` | 303 | `10.10.10.213` |

High-level workflow:

```text
Developer Workstation
        |
        | Terraform
        v
Proxmox VE
        |
        | Ubuntu 24.04 cloud-init template
        v
Terraform-managed VMs
        |
        | Ansible
        v
Kubernetes cluster with kubeadm
        |
        | Helm
        v
NGINX lab application
        |
        | GitHub Actions
        v
Custom container image in GHCR
        |
        | kube-prometheus-stack
        v
Prometheus, Grafana, Alertmanager
```

## Tools Used

| Tool | Purpose |
|---|---|
| Proxmox VE | Hypervisor for running the lab VMs |
| Terraform | VM provisioning and infrastructure-as-code |
| Ansible | Server configuration and Kubernetes bootstrap automation |
| Kubernetes | Container orchestration platform |
| kubeadm | Kubernetes cluster initialization and node joining |
| Helm | Kubernetes application packaging and deployment |
| GitHub Actions | CI/CD workflows for validation and image publishing |
| GitHub Container Registry | Container image registry |
| Prometheus | Metrics collection and alerting |
| Grafana | Metrics visualization |
| kube-prometheus-stack | Prometheus Operator-based monitoring stack |
| NGINX | Lab application and metrics target |

## Infrastructure Provisioning with Terraform

The lab uses Terraform to provision the active Kubernetes nodes on Proxmox.

Terraform creates three virtual machines from an Ubuntu 24.04 cloud-init template:

- `k8s-tf-cp-01`

- `k8s-tf-worker-01`

- `k8s-tf-worker-02`

The Terraform configuration defines:

- VM IDs

- Hostnames

- Static IP addresses

- CPU and memory allocation

- Cloud-init configuration

- Proxmox target node, bridge, and storage pool

The project originally started with manually cloned VMs, but was later migrated to Terraform-managed infrastructure for repeatability and better infrastructure-as-code practice.

A key design decision was to use the `bpg/proxmox` Terraform provider after encountering permission limitations with the earlier Proxmox provider. This allowed the infrastructure workflow to proceed cleanly with the Proxmox API.

## Configuration Management with Ansible

After Terraform provisions the VMs, Ansible configures the operating system and Kubernetes prerequisites.

The Ansible inventory defines the active cluster groups:

- `k8s_control_plane`

- `k8s_workers`

- `k8s_cluster`

The common baseline playbook performs tasks such as:

- Updating apt cache

- Installing common packages

- Setting the timezone

- Ensuring `qemu-guest-agent` is installed and running

- Disabling swap

The playbook was run multiple times to confirm idempotency. A clean second run confirmed that Ansible could repeatedly enforce the desired state without unnecessary changes.
Kubernetes Prerequisites

A dedicated Ansible playbook prepares all nodes for Kubernetes by configuring:

- Required kernel modules:

    - `overlay`

    - `br_netfilter`

- Required sysctl settings:

    - `net.bridge.bridge-nf-call-iptables = 1`

    - `net.bridge.bridge-nf-call-ip6tables = 1`

    - `net.ipv4.ip_forward = 1`

- `containerd`

- Kubernetes apt repository

- `kubelet`

- `kubeadm`

- `kubectl`

- Package holds for Kubernetes components

The container runtime is configured to use `SystemdCgroup`, which aligns containerd with kubelet expectations.

## Kubernetes Bootstrap with kubeadm

The cluster is bootstrapped using Ansible playbooks around `kubeadm`.

The control plane playbook:

- Initializes Kubernetes with `kubeadm init`

- Uses the Terraform-managed control-plane IP as the API server advertise address

- Configures the pod network CIDR for Flannel

- Copies the admin kubeconfig to the devops user

- Installs Flannel CNI

- Generates a worker join command

The worker join playbook:

- Retrieves a fresh join command from the control plane

- Joins each worker node to the cluster

- Avoids rejoining nodes that already have kubelet configuration

The final cluster consists of one control plane and two worker nodes.

## Application Deployment with Helm

The lab application is packaged as a Helm chart named nginx-lab.

The chart deploys:

- An NGINX-based application

- A Kubernetes Deployment

- ClusterIP and/or NodePort service configuration

- Ingress resource

- NGINX exporter sidecar

- ServiceMonitor for Prometheus scraping

- PrometheusRule for alerting

Helm values are used to configure deployment behavior, image settings, service ports, ingress hosts, and monitoring integration.

The active app ingress hostname uses the Terraform-managed cluster IP:

- `nginx-lab.10.10.10.211.nip.io`

## Custom Container Image and CI/CD

The project includes a custom NGINX container image under `app/nginx`.

GitHub Actions builds the image and publishes it to GitHub Container Registry.

The workflow performs the following:

- Builds the custom NGINX image

- Publishes the image to GHCR

- Tags images with immutable commit SHA tags

- Updates the Helm chart values file with the new image tag

- Commits the updated tag back to the repository

This replaced the earlier use of a mutable `latest` image tag with immutable image references.

The repository also includes validation workflows for Kubernetes manifests and Helm charts, including:

- Helm linting

- Helm template rendering

- Kubernetes schema validation with kubeconform

## Monitoring and Observability

Monitoring is provided by `kube-prometheus-stack`.

The monitoring stack includes:

- Prometheus

- Grafana

- Alertmanager

- kube-state-metrics

- node-exporter

- Prometheus Operator

Prometheus discovers the NGINX lab application through a `ServiceMonitor`.

A key troubleshooting lesson was that the `ServiceMonitor` and `PrometheusRule` labels must match the release selector used by the Prometheus instance. In this environment, the required label is:

```yaml
release: kube-prometheus-stack
```

Once the labels were aligned, Prometheus discovered the `nginx-lab` target and Grafana queries returned data.

Example Prometheus query:

```promql
nginx_http_requests_total{namespace="devops-lab"}
```

Grafana was configured to visualize the NGINX metrics collected by Prometheus.

## Troubleshooting Highlights

Several realistic troubleshooting scenarios occurred during the project.

### Terraform Provider Permissions

The initial Terraform provider encountered Proxmox API permission issues involving missing `VM.Monitor` permissions. After repeated troubleshooting, the project switched to the `bpg/proxmox` provider, which resolved the provisioning workflow.

### Host Resource Constraints

Before applying Terraform changes, RAM usage on the Proxmox host was checked. The earlier manually created cluster was shut down before provisioning the Terraform-managed cluster to avoid memory pressure.

### Git Non-Fast-Forward Push

A push was rejected because the remote branch had changes not present locally. The issue was resolved by rebasing before pushing:

```bash
git pull --rebase origin main
git push origin main
```

This became the standard Git workflow for the project.

### Kubeconfig Pointing to Old Cluster

After rebuilding the cluster, local `kubectl` and `helm` commands were still pointing to the previous API server at `10.10.10.201`.

The fix was to copy the kubeconfig from the new control plane and set `KUBECONFIG` to the new file:

```bash
scp devops@10.10.10.211:/home/devops/.kube/config ~/.kube/proxmox-tf-lab
export KUBECONFIG=$HOME/.kube/proxmox-tf-lab
```

### Prometheus Target Discovery

The rebuilt cluster initially had no `nginx-lab` Prometheus target. The `ServiceMonitor` existed, but Prometheus was not discovering it until the release label matched the monitoring stack selector.

This reinforced the importance of understanding how the Prometheus Operator discovers custom resources.

## Current Active Cluster

| Role | Hostname | VM ID | IP Address |
|---|---|---|---|
| Control plane | `k8s-tf-cp-01` | 301 | `10.10.10.211` |
| Worker | `k8s-tf-worker-01` | 302 | `10.10.10.212` |
| Worker | `k8s-tf-worker-02` | 303 | `10.10.10.213` |

The previous manually configured cluster used VM IDs `201-203` and IP addresses `10.10.10.201-203`. That cluster has been shut down and replaced by the Terraform-managed cluster.

## Skills Demonstrated

This project demonstrates hands-on experience with:

- Infrastructure-as-code

- Configuration management

- Kubernetes cluster administration

- Linux server automation

- Helm chart development

- CI/CD pipeline design

- Container image publishing

- Kubernetes monitoring

- Prometheus Operator resources

- Grafana dashboard validation

- Git troubleshooting

- Debugging real infrastructure issues

- Documentation of a technical project

## Final Validation Commands

Useful commands for validating the current environment:

```bash
terraform -chdir=terraform/proxmox-vms output
```

```bash
ansible-playbook ansible/playbooks/ping.yaml
```

```bash
kubectl get nodes -o wide
kubectl get pods -A
helm list -A
```

```bash
kubectl get servicemonitor -A
kubectl get prometheusrule -A
```

```bash
kubectl get ingress -A
```

## Summary

This lab demonstrates a complete DevOps workflow from infrastructure provisioning through application deployment and monitoring.

The project began with manually configured Kubernetes nodes and evolved into a repeatable infrastructure-as-code workflow using Terraform and Ansible. The final environment is a Terraform-provisioned, Ansible-configured Kubernetes cluster running a Helm-deployed application with CI/CD automation and Prometheus/Grafana observability.
