# Proxmox Ubuntu Cloud-Init Template

## Purpose

This document describes how I created a reusable Ubuntu 24.04 cloud-init template in Proxmox for my DevOps lab.

## Template Details

| Setting | Value |
|---|---|
| Template VM ID | 9000 |
| Template Name | ubuntu-2404-cloudinit-template |
| OS | Ubuntu Server 24.04 LTS |
| Disk Size | 32 GB |
| vCPU | 2 |
| RAM | 2048 MB |
| Network Bridge | vmbr0 |
| Cloud-Init User | devops |
| IP Assignment | DHCP |
| QEMU Guest Agent | Enabled |

## Commands Used

```bash
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

apt update
apt install -y libguestfs-tools

virt-customize -a noble-server-cloudimg-amd64.img --install qemu-guest-agent

qm create 9000 \
  --name ubuntu-2404-cloudinit-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --ostype l26 \
  --agent enabled=1

qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm

qm set 9000 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:vm-9000-disk-0

qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm resize 9000 scsi0 32G
qm set 9000 --ciuser devops
qm set 9000 --sshkeys /tmp/devops.pub
qm set 9000 --ipconfig0 ip=dhcp
qm template 9000
