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
│   ├── homelab.ini
│   └── group_vars/
│       └── all.yaml
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