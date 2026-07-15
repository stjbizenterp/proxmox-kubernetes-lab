# Proxmox VM Provisioning with Terraform

## Overview

This Terraform project provisions Ubuntu cloud-init VMs on Proxmox for a Kubernetes lab environment.

The VMs are cloned from an existing Ubuntu 24.04 cloud-init template.

## Provider

This lab uses the `bpg/proxmox` Terraform provider.

An earlier attempt used the `telmate/proxmox` provider, but API token permission checks repeatedly failed with a missing `VM.Monitor` permission despite the token having Administrator permissions. The lab was migrated to the BPG provider for better compatibility with the current Proxmox environment.

## Managed VMs

| Hostname | VM ID | IP Address | CPU | Memory |
|--|--|--|--|--|
| k8s-tf-cp-01 | 301 | 10.10.10.211 | 2 | 4096 MB |
| k8s-tf-worker-01 | 302 | 10.10.10.212 | 2 | 4096 MB |
| k8s-tf-worker-02 | 303 | 10.10.10.213 | 2 | 4096 MB |

## Proxmox Environment

| Setting | Value |
|--|--|
| Proxmox node | `pve` |
| Template VM ID | `9000` |
| Template name | `ubuntu-2404-cloudinit-template` |
| VM storage | `local-lvm` |
| Network bridge | `vmbr0` |
| Gateway | `10.10.10.1` |
| DNS | `10.10.10.1` |

## Files

- `main.tf`

- `variables.tf`

- `outputs.tf`

- `terraform.tfvars.example`

## Usage

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit real local values:

```bash
nano terraform.tfvars
```

Initialize Terraform:

```bash
terraform init
```

Format and validate:

```bash
terraform fmt
terraform validate
```

Review the plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

View outputs:

```bash
terraform output
```

Destroy test VMs when finished:

```bash
terraform destroy
```

## Validation

After applying, verify VM creation:

```bash
terraform output
qm list | grep k8s-tf
```

Verify SSH access:

```bash
ssh devops@10.10.10.211 hostname
ssh devops@10.10.10.212 hostname
ssh devops@10.10.10.213 hostname
```

## Secret Handling

The real `terraform.tfvars` file is ignored by Git and must not be committed.

The repository includes only:

```text
terraform.tfvars.example
```

Terraform state files are also ignored by Git.

## Notes

This project initially provisions VMs separate from the manually built Kubernetes cluster.

The manually built cluster used:

```text
10.10.10.201-203
```

The Terraform-managed VMs use:

```text
10.10.10.211-213
```

This avoids disrupting the working Kubernetes cluster while Terraform provisioning is tested.