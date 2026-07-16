# Ansible Configuration Management

## Overview

This directory contains Ansible inventory and playbooks for configuring Terraform-provisioned Proxmox VMs.

The Ansible milestone demonstrates configuration management on top of infrastructure provisioned with Terraform.

## Target Nodes

| Group | Hostname | IP Address |
|---|---|---|
| k8s_control_plane | k8s-tf-cp-01 | 10.10.10.211 |
| k8s_workers | k8s-tf-worker-01 | 10.10.10.212 |
| k8s_workers | k8s-tf-worker-02 | 10.10.10.213 |

## Directory Structure

```text
ansible/
├── inventory/
│   ├── group_vars/
│   │   └── all.yaml
│   └── homelab.ini
├── playbooks/
│   ├── ping.yaml
│   └── common.yaml
└── README.md
```

## Inventory

Inventory file:

```text
ansible/inventory/homelab.ini
```

The inventory defines:

- `k8s_control_plane`

- `k8s_workers`

- `k8s_cluster`

## Connectivity Test

Run an ad hoc ping:

```bash
ansible -i ansible/inventory/homelab.ini k8s_cluster -m ping
```

Run the ping playbook:

```bash
ansible-playbook -i ansible/inventory/homelab.ini ansible/playbooks/ping.yaml
```

## Common Baseline

Run the common baseline playbook:

```bash
ansible-playbook -i ansible/inventory/homelab.ini ansible/playbooks/common.yaml
```

The common baseline playbook:

- Updates apt cache

- Installs common troubleshooting packages

- Sets timezone

- Enables and starts `qemu-guest-agent`

- Disables swap

- Removes swap entries from `/etc/fstab`

## Variables

Shared variables are defined in:

```text
ansible/group_vars/all.yaml
```

## Notes

These playbooks target Terraform-created VMs:

```text
10.10.10.211-213
```

The earlier manually configured Kubernetes cluster used:

```text
10.10.10.201-203
```

## Kubernetes Prerequisites

Run the Kubernetes prerequisites playbook:

```bash
ansible-playbook ansible/playbooks/kubernetes-prereqs.yaml
```

This playbook configures all Kubernetes nodes by:

- Loading `overlay` and `br_netfilter` kernel modules

- Persisting required kernel modules across reboots

- Configuring Kubernetes networking sysctl settings

- Installing and configuring `containerd`

- Enabling `SystemdCgroup` for containerd

- Adding the Kubernetes apt repository

- Installing `kubelet`, `kubeadm`, and `kubectl`

- Holding Kubernetes packages to avoid unintended upgrades

Verification examples:

```bash
ssh devops@10.10.10.211 'containerd --version && kubeadm version && kubelet --version && kubectl version --client'
ssh devops@10.10.10.211 'swapon --show'
ssh devops@10.10.10.211 'sysctl net.ipv4.ip_forward net.bridge.bridge-nf-call-iptables'
ssh devops@10.10.10.211 "sudo grep SystemdCgroup /etc/containerd/config.toml"
```

Be careful with nested code fences if editing manually. If it gets annoying, just paste the section without the inner fenced command blocks.