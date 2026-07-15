output "vm_names" {
  description = "Terraform-managed Kubernetes VM names"
  value       = [for vm in proxmox_virtual_environment_vm.k8s_nodes : vm.name]
}

output "vm_ids" {
  description = "Terraform-managed Kubernetes VM IDs"
  value       = [for vm in proxmox_virtual_environment_vm.k8s_nodes : vm.vm_id]
}

output "vm_ips" {
  description = "Terraform-managed Kubernetes VM IP addresses"
  value = {
    for name, config in local.k8s_nodes : name => config.ip
  }
}