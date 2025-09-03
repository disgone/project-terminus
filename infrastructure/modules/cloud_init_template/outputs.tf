output "template_id" {
  description = "VM ID of the created template"
  value       = var.vm_id
}

output "template_name" {
  description = "Name of the created template"
  value       = var.template_name
}

output "target_node" {
  description = "Proxmox node where template was created"
  value       = var.target_node
}

output "storage_pool" {
  description = "Storage pool used for the template"
  value       = var.storage_pool
}

output "cloud_init_file" {
  description = "Path to the cloud-init vendor file"
  value       = "/var/lib/vz/snippets/${var.cloud_init_file_name}"
}

output "tags" {
  description = "Tags applied to the template"
  value       = var.tags
}

output "template_ready" {
  description = "Indicates if template creation is complete"
  value       = true
  depends_on  = [null_resource.convert_to_template]
}
