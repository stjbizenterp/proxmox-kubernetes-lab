variable "proxmox_api_url" {
  description = "Proxmox API endpoint, for example https://10.10.10.10:8006"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID, for example terraform@pve!lab"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Target Proxmox node name"
  type        = string
  default     = "pve"
}

variable "template_vmid" {
  description = "VM ID of the Proxmox cloud-init template"
  type        = number
  default     = 9000
}

variable "vm_storage" {
  description = "Proxmox storage for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Default gateway for VM networking"
  type        = string
  default     = "10.10.10.1"
}

variable "nameserver" {
  description = "DNS nameserver for VMs"
  type        = string
  default     = "10.10.10.1"
}

variable "ci_user" {
  description = "Cloud-init user"
  type        = string
  default     = "devops"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key used for cloud-init"
  type        = string
}