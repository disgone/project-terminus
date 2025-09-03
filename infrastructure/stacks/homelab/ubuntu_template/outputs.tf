# Template Information
output "template_id" {
  description = "ID of the created template"
  value       = module.ubuntu_lts_template.template_id
}

output "template_name" {
  description = "Name of the created template"
  value       = module.ubuntu_lts_template.template_name
}

output "target_node" {
  description = "Proxmox node where the template was created"
  value       = module.ubuntu_lts_template.target_node
}

output "storage_pool" {
  description = "Storage pool used for the template"
  value       = module.ubuntu_lts_template.storage_pool
}

output "tags" {
  description = "Tags applied to the template"
  value       = module.ubuntu_lts_template.tags
}

output "cloud_init_file" {
  description = "Path to the cloud-init vendor configuration file"
  value       = module.ubuntu_lts_template.cloud_init_file
  sensitive   = false
}

# Configuration Summary
output "configuration_summary" {
  description = "Summary of the template configuration"
  value = {
    ubuntu_version = var.ubuntu_version
    memory_mb      = var.memory
    cpu_cores      = var.cpu_cores
    cpu_sockets    = var.cpu_sockets
    cpu_type       = var.cpu_type
    disk_size      = var.disk_size
    network_bridge = var.network_bridge
    vm_id          = var.template_vm_id
  }
}
