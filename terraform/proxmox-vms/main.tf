terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
}

locals {
  k8s_nodes = {
    k8s-tf-cp-01 = {
      vmid   = 301
      ip     = "10.10.10.211"
      cores  = 2
      memory = 2048
    }
    k8s-tf-worker-01 = {
      vmid   = 302
      ip     = "10.10.10.212"
      cores  = 2
      memory = 2048
    }
    k8s-tf-worker-02 = {
      vmid   = 303
      ip     = "10.10.10.213"
      cores  = 2
      memory = 2048
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_nodes" {
  for_each = local.k8s_nodes

  name      = each.key
  node_name = var.proxmox_node
  vm_id     = each.value.vmid

  description = "Terraform-managed Kubernetes lab VM"

  tags = [
    "terraform",
    "kubernetes",
    "devops-lab"
  ]

  started = true

  clone {
    vm_id        = var.template_vmid
    full         = true
    datastore_id = var.vm_storage
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = 40
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.vm_storage

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = [var.nameserver]
    }

    user_account {
      username = var.ci_user
      keys     = [trimspace(file(var.ssh_public_key_path))]
    }
  }

  operating_system {
    type = "l26"
  }
}